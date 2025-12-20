# Tools for Cybersecurity Research

_⚠️ Research and authorized testing only. Please do not use against systems without permission._

---

## 📚 Research Cheatsheets
A collection of personal reference guides for vulnerability research, N-day analysis, and payload crafting.

| Cheatsheet | Focus Area |
| :--- | :--- |
| **[SQL Injection (SQLi)](cheatsheets/sqli.md)** | Detection, Union-based extraction, Blind timing attacks, and Out-of-Band exfiltration. |
| **[XSS Payloads](cheatsheets/xss.md)** | Context-specific vectors, Modern WAF evasion, Polyglots, and Client-Side Template Injection. |
| **[SSRF & Cloud](cheatsheets/ssrf.md)** | Cloud metadata endpoints (AWS, GCP, Azure), protocol wrappers, and filter bypasses. |
| **[RCE & Command Injection](cheatsheets/rce.md)** | Separator logic, space/character evasion (Linux/Windows), and Blind RCE techniques. |
| **[Dangerous Functions](cheatsheets/dangerous_functions.md)** | White-box source code review patterns for C, PHP, Python, and Java. |
| **[Patch Diffing](cheatsheets/patch_diffing.md)** | Workflow for analyzing N-Day vulnerabilities, diffing commits, and hunting for variants. |

---

## 🛠️ My Custom Scripts
Automation scripts for Bug Bounty reconnaissance and fuzzing.

### 1. [`recon.sh`](my_custom_scripts/recon.sh)
Automates subdomain enumeration and live host detection.
* **Requirements:** `subfinder`, `httpx-toolkit`
* **Usage:** Enumerates subdomains and checks for live web servers.

### 2. [`ffuf_recon.sh`](my_custom_scripts/ffuf_recon.sh)
Automated directory and parameter fuzzing wrapper.
* **Requirements:** `ffuf`, SecLists (or custom wordlists)
* **Configuration:** Update headers with your bug bounty username/email in the script before running.

#### ⚡ Quick Setup & Usage

```bash
# 1. Clone the repository
git clone https://github.com/skraft9/cybersecurity-research-tools.git
cd cybersecurity-research-tools

# 2. Give execution rights to scripts
chmod +x my_custom_scripts/*.sh

# 3. Run a script
./my_custom_scripts/recon.sh

```

---

## 🌍 Popular External Tools

Industry-standard tools I use for deep-dive analysis.

* **[CodeQL](https://github.com/github/codeql-cli-binaries/releases/)** — Heavyweight source code analysis. Turns code into a queryable database to hunt for complex patterns.
* **[Semgrep](https://github.com/semgrep/semgrep)** — Lightweight static analysis. Excellent for quickly "grepping" for dangerous function calls across large codebases.
* **[Caido](https://github.com/caido/caido)** — Modern, lightweight web proxy (alternative to Burp Suite).
* **[Dalfox](https://github.com/hahwul/dalfox)** — Powerful automated XSS scanner.
* **[XSSHunter](https://github.com/trufflesecurity/xsshunter)** — Essential for catching Blind XSS callbacks.

```

```
