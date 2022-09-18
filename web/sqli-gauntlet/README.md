# SQLi gauntlet writeup

- there are 3 users you have to compromise through SQLi: 'carlos', 'admin', and 'superadmin'
    - each user provides a flag so there are 3 flags total
- there is a hint commented into the homepage HTML suggesting players look for valid users
    - to get these valid users, look through the blog post comments; all three users are there
    - an additional hint is the vulnerable SQL statement being used

- if players decide to enumerate further and discover the robots.txt file, there are additional resources and a red herring

### User flag
- 'user' has no filters, but any password input with whitespace is detected and invalidated
    - the intended solution is to learn about how comments - `e.g., /* comment */` - can be used to create whitespace without being detected. [Portswigger has an article which talks about this](https://portswigger.net/support/sql-injection-bypassing-common-filters). So, the intended bypass would be: `junk'/**/OR/**/'1'='1`.
        - using plus ( + ) is also valid in most cases
    - another solution would be to just remove spaces. It is possible to write some pretty elaborate SQL statements that work without spaces; as long as statements dont clash - `e.g., SELECT*FROMcredsWHERE...`. So `junk'OR'1'='1` works perfectly fine. 


### Admin flag
- 'admin' has two extra filters: 'OR' and '1'
    - SQL is case insensitive, so 'OR' can be bypassed by using any other combination of lower/uppercase characters.
    - '1' is bypassed by forming any other comparison that creates a True statement - `e.g., 2=2, x=x, cactus=cactus etc`
        - '1' is a pretty stupid filter to have, but I want players to understand how an SQLi bypass works.


### Superadmin flag
- 'superadmin' has two more filters: 'or' and '='
    - Once again, SQL is case insensitive; 'oR' and 'Or' are still valid options
    - A bit of thinking is required for the '=' filter, because you can no longer create true statements using the '=' operator 
        - you could use the 'true' value instead
        - you could use the LIKE operator where you compare a column value to a wildcard of anything - `e.g., OR username LIKE '%`
            - the '%' wildcard represents zero, one, or multiple characters
            - the column value can be seen in the earlier hint, where the full SQL statement being used is exposed
        - thus, `junk'oR/**/true--` and `junk'oR/**/username/**/like'%` are both valid SQLis
        - could also create a true statement using a different operator: `e.g., 100>1`
        







