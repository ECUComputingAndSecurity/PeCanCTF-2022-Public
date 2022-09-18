# Robotic uprising writeup

- the robots.txt file is used to give instructions to web bots - such as search engine crawlers - about locations on a site that shouldn't be crawled and indexed 
- CWE-200 is the exposure of sensitive information to an unauthorised actor
    - using a robots.txt file is not a security threat by default. Using it incorrectly, assuming that it provides protection against unauthorised access, is when it becomes a threat.
- the solution is to visit the robots.txt file and find the directory with sensitive information
    - /tokens/ is the sensitive directory and contains the flag inside when visited
