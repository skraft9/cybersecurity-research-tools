# Tools for Cybersecurity Research

_⚠️For research and authorized testing only. Please do not use against systems without permission._

---
## Popular Tools

[CodeQL](https://github.com/github/codeql-cli-binaries/releases/)

[Semgrep](https://github.com/semgrep/semgrep)

---
## Custom Scripts

`recon.sh` requires subfinder & httpx-toolkit.

`ffuf_recon.sh` requires wordlists.  update headers with your username.

---

- Use any text editor to create a new file (using nano for this example)

`nano recon.sh`

-  Paste in the contents of the script from `recon.sh`

-  Assign the file executable rights

`sudo chmod +x`

-  Execute bash script

`./recon.sh`

-  Enter the target domain

Review the responses from the web servers.

> Note: `httpx-toolkit` is configured to follow re-directs.
