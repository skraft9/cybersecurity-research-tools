# ☢️ Dangerous Functions & Source Code Review Cheatsheet

> **⚠️ Context Matters:** Presence of these functions isn't an instant vulnerability. You must verify if **user-controlled input** reaches these sinks without sanitization.

---

## 🦕 1. C / C++ (Memory Corruption & Command Injection)

*The classic targets for buffer overflows and binary exploitation.*

### Buffer Overflow Sinks (Stack/Heap)

*These functions do not check the length of the source buffer.*

| Function | Danger | Safer Alternative |
| --- | --- | --- |
| `gets()` | **CRITICAL.** Impossible to use safely. Reads until newline. | `fgets()` |
| `strcpy(dest, src)` | Copies until null byte. Overflows `dest` if `src` is larger. | `strncpy()` (be careful with null-termination) |
| `strcat(dest, src)` | Concatenates `src` to `dest`. | `strncat()` |
| `sprintf(dest, fmt)` | Prints to buffer without length check. | `snprintf()` |
| `vsprintf()` | Variadic version of `sprintf`. | `vsnprintf()` |

### Command Injection

*Look for user input being concatenated into these strings.*

```c
system("ls " + input);  // VULNERABLE
popen("cat " + input, "r");
execlp(...);
execvp(...);

```

### Format String

*If the format string itself is user-controlled.*

```c
printf(user_input); // VULNERABLE: %x %n can read/write memory
syslog(priority, user_input);
fprintf(stderr, user_input);

```

### Race Conditions (TOCTOU)

*Time-of-Check to Time-of-Use.*

* **Pattern:** `access(file)` followed by `open(file)`.
* **Exploit:** Swap the file between the check and the open.

---

## 🐘 2. PHP (Web Vulnerabilities)

*Common in legacy web apps and CMS plugins.*

### Remote Code Execution (RCE)

```php
eval($input);           // Executes string as PHP code
assert($input);         // Identical to eval() in older PHP
system($cmd);           // Executes shell command
shell_exec($cmd);       // Same as backticks `cmd`
passthru($cmd);
exec($cmd);
proc_open($cmd);
popen($cmd);
pcntl_exec($path);

```

### File Inclusion (LFI / RFI)

*Allows reading local files or executing remote scripts.*

```php
include($page);
require($page);
include_once($page);
require_once($page);

```

### Object Injection

*The PHP equivalent of deserialization attacks.*

```php
unserialize($data);  // Triggers __wakeup() or __destruct() magic methods

```

---

## 🐍 3. Python (Modern Automation & Web)

### OS Command Injection

```python
import os
os.system("cmd " + input)
os.popen("cmd " + input)

import subprocess
# Vulnerable if shell=True is used with string concatenation
subprocess.call("cmd " + input, shell=True) 
subprocess.Popen("cmd " + input, shell=True)

```

### Deserialization (Pickle)

*Never unpickle untrusted data. It is essentially RCE.*

```python
import pickle
pickle.loads(user_input) 
_pickle.loads(user_input)
yaml.load(input) # PyYAML (Old versions require Loader=SafeLoader)

```

### SQL Injection (ORM Bypasses)

*Watch for f-strings or format strings in queries.*

```python
# VULNERABLE
cursor.execute(f"SELECT * FROM users WHERE name = '{input}'") 
cursor.execute("SELECT * FROM users WHERE name = '%s'" % input)

# SAFE (Parameterized)
cursor.execute("SELECT * FROM users WHERE name = %s", (input,))

```

---

## ☕ 4. Java (Enterprise Apps)

### Deserialization

*Look for classes implementing `Serializable` and inputs reading objects.*

```java
ObjectInputStream.readObject();

```

### XML External Entity (XXE)

*If XML parsers are not configured to disable DTDs.*

```java
DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
// Vulnerable if setExpandEntityReferences(false) is NOT called
dbf.newDocumentBuilder().parse(input);

```

### Command Execution

```java
Runtime.getRuntime().exec(input); // Splitting args is tricky here
ProcessBuilder(input).start();

```

---

## 🔍 5. Grep / Semgrep Patterns

*Copy-paste these into your terminal to hunt fast.*

**Quick "Grep" Hunt (Generic)**

```bash
grep -RnE "system\(|exec\(|popen\(|eval\(|strcpy\(|strcat\(|memcpy\(|unserialize\(|pickle\.loads" .

```

**Semgrep Rules (Better than Grep)**
*If you use Semgrep (recommended), use these rulesets:*

```bash
semgrep --config=p/c --config=p/security-audit .
semgrep --config=p/python --config=p/owasp-top-ten .

```

---
