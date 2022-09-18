# Check your facts writeup

- need to infer that the website uses a database to store facts
- query used in application is `"SELECT * FROM facts WHERE category='%s';" % category`
    - this is vulnerable to SQL injection
- inspect HTTP requests when clicking the buttons
    - could do this through browser dev tools, but the preferred tool is Burp Suite
    - `query=` should be a focus point
    - querying for the 'secret' row will return another hint, but not the flag (`query=secret`)
    - manual fuzzing for SQLi will return database errors (`using '`)
- manual exploitation is encouraged but players can also use a wordlist (e.g., `usr/share/wordlists/wfuzz/Injections/SQL.txt`)
- we need an exploit that dumps all rows from the 'facts' table 
    - doing this will reveal the secret row (called **$ecr3tR0w**) containing the flag
    - `' OR '1'='1` is a common SQLi exploit and will work against the query
        - this will make the query return all (*) rows from the facts table, where the category is **either** the category specified **or** is True (1=1)
    - any other variation of this exploit will also work (e.g., `' OR 0=0 --`, `' OR 'a'='a`, `' OR '1'='1'--` etc )
- returns the flag along with the rest of the facts
   
