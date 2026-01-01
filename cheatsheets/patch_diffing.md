# Patch Diffing & N-Day Research Cheatsheet

Analyze a security patch (diff) to understand the vulnerability, recreate the exploit, and hunt for bypasses (variants).

---

## 1. Obtaining the Diff

### A. GitHub UI Strategies

**The "Compare" View:**
`https://github.com/elastic/kibana/compare/v8.10.0...v8.10.1`
> Use this to see everything changed between two minor versions.

- Search Closed PRs with keywords: `security`, `fix`, `cve`, `sanitize`, `escape`, `harden`.
- Look for "Obscure" commit messages like "update logic" or "fix handling" merged right before a release.
- If you know the vulnerable file (from a CVE description), use `git blame` or the File History to find the most recent change.



### B. Command Line

*Clone the repo locally for speed.*

```bash
# 1. Clone the target
git clone https://github.com/elastic/kibana.git
cd kibana

# 2. Fetch all tags
git fetch --tags

# 3. Diff two tags (Output to file for easy reading)
git diff v8.10.0 v8.10.1 > release_diff.patch

# 4. Diff specific file across versions
git diff v8.10.0 v8.10.1 -- path/to/vulnerable/file.ts

```

---

## 2. Reading the Diff

*Don't just look at the code; look at the **logic change**.*

### A. The "Sanitization" Pattern (XSS/Injection)

*Did they wrap a variable in a new function?*

**The Diff:**

```diff
-  return `<div>${userInput}</div>`;
+  return `<div>${escapeHtml(userInput)}</div>`;

```

**Analysis:**

* **Vulnerability:** XSS (Reflected/Stored).
* **Trigger:** `userInput` contained raw HTML.
* **Bypass Hunt:** Check `escapeHtml`. Does it handle single quotes? Backticks? URL encoding?

### B. The "Logic Check" Pattern (IDOR / Auth)

*Did they add an `if` statement checking permissions?*

**The Diff:**

```diff
+  if (!user.canRead(resource)) {
+      throw new ForbiddenError();
+  }
   return database.fetch(resource);

```

**Analysis:**

* **Vulnerability:** IDOR / Missing Access Control.
* **Trigger:** Requesting a resource ID you don't own.
* **Bypass Hunt:** Can I control `resource` type? Is `user.canRead` checking the right scope?

### C. The "Input Validation" Pattern (RCE / Prototype Pollution)

*Did they ban specific keys or characters?*

**The Diff:**

```diff
-  merge(target, source);
+  if (key === '__proto__' || key === 'constructor') continue;
+  merge(target, source);

```

**Analysis:**

* **Vulnerability:** Prototype Pollution.
* **Trigger:** JSON input with `__proto__`.
* **Bypass Hunt:** Did they block `prototype`? Is the check recursive? Can I use `constructor.prototype`?

---

## 3. Tools for Visualization

*Raw diffs are hard to read. Use these tools to see the flow.*

**Visual Studio Code (GitLens)**
* Right-click file -> "Open Changes with Previous Revision".
* *Essential for tracing where the variable came from in the code.*


**Diff2Html**
* Converts `.patch` files to pretty HTML side-by-side views.


**Meld / Beyond Compare**
* GUI tools for comparing entire directory trees (great for seeing if a fix involved multiple files).



---

## 4. The "Variant Hunting" Workflow

*The patch fixes **one** instance. Developers often copy-paste code. Find the others.*

**Identify the Sink**
* The patch fixed a call to `eval(input)`.


**Search the Codebase**
* Use grep/Semgrep to find *other* calls to `eval()` or similar dangerous functions.
* `grep -r "eval(" .`


**Check for Missing Patches**
* Did they fix it in `profile.ts` but forget `settings.ts`?


**Check for "Weak" Fixes**
* Did they use a regex blacklist? (`replace(/<script>/g, "")`).
* *Bypass:* `<SCRIPT>` or `<scr<script>ipt>`.



---

## 5. Recreating the Exploit (POC)

*You haven't understood the patch until you can pop a shell on the **pre-patch** version.*

**Checkout the Vulnerable Version**
* `git checkout v8.10.0`


**Setup the Environment:**
* Run the app (Docker is usually best for Kibana).


**Trace the Input:**
* Use `console.log()` (or breakpoints) in the vulnerable file to see what your input looks like *right before* it hits the sink.


**Fire the Payload:**
* Verify the crash/alert.


**Verify the Fix:**
* `git checkout v8.10.1`
* Run the same payload. It should fail.
