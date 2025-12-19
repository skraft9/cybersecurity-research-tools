# Tools for Cybersecurity Research

_⚠️For research and authorized testing only. Please do not use against systems without permission._

---
## Popular Tools

[CodeQL](https://github.com/github/codeql-cli-binaries/releases/) — Useful for heavyweight source code analysis, turn code into a database, write advanced queries to hunt for dangerous code patterns.

[Semgrep](https://github.com/semgrep/semgrep) — Useful for lightweight source code analysis, quickly hunt for dangerous code patterns.

[XSSHunter](https://github.com/trufflesecurity/xsshunter) — Useful for Blind XSS Confirmation.

[Dalfox](https://github.com/hahwul/dalfox) — Useful for Automated XSS Hunting.

---
## Custom Scripts For Bug Bounty

`recon.sh` 

Requirements
* subfinder
* httpx-toolkit

`ffuf_recon.sh` 

* Requires wordlists
* Update headers with your bug bounty username (optional).

---

- Use nano text editor to create a new file 

```bash
nano recon.sh
```

-  Paste in the contents of the script from `recon.sh`

-  Assign the file executable rights

```bash
sudo chmod +x
```

-  Execute bash script

```bash
./recon.sh
```

-  Enter the target domain

Review the responses from the web servers.

> Note: `httpx-toolkit` is configured to follow re-directs.
