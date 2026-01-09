# Render a Markdown (`.md`) 

file using **HTML + JavaScript**, depending on whether the Markdown is **local** or **fetched remotely**.

---

## ✅ Option 1: Render Markdown in the Browser (Recommended)

Use a **Markdown parser library** like **marked.js**.

### 1️⃣ Basic HTML

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Markdown Renderer</title>
</head>
<body>

<div id="content"></div>

<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="app.js"></script>
</body>
</html>
```

---

### 2️⃣ JavaScript (Fetch & Render Markdown)

```javascript
fetch('README.md')
  .then(response => response.text())
  .then(markdown => {
    document.getElementById('content').innerHTML = marked.parse(markdown);
  })
  .catch(err => console.error(err));
```

📌 **Notes**

* `README.md` must be served via **HTTP** (won’t work with `file://`)
* Use a local server:

  ```bash
  python -m http.server
  ```

---

## ✅ Option 2: Render Inline Markdown (No Fetch)

If your Markdown is already in JavaScript:

```html
<div id="content"></div>

<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script>
  const md = `
  # Hello Markdown

  - Item 1
  - Item 2

  **Bold Text**
  `;

  document.getElementById('content').innerHTML = marked.parse(md);
</script>
```

---

## 🔒 Security Tip (IMPORTANT)

If Markdown content is **user-generated**, sanitize HTML to prevent XSS.

```html
<script src="https://cdn.jsdelivr.net/npm/dompurify@3.0.6/dist/purify.min.js"></script>
<script>
  const dirty = marked.parse(markdown);
  const clean = DOMPurify.sanitize(dirty);
  document.getElementById('content').innerHTML = clean;
</script>
```

---

## 🧰 Popular Markdown Libraries

| Library         | Notes                |
| --------------- | -------------------- |
| **marked**      | Fast, simple         |
| **markdown-it** | CommonMark compliant |
| **showdown**    | Older but stable     |

Example with **markdown-it**:

```html
<script src="https://cdn.jsdelivr.net/npm/markdown-it/dist/markdown-it.min.js"></script>
<script>
  const md = window.markdownit();
  document.getElementById('content').innerHTML = md.render('# Hello');
</script>
```

---

## 🖥️ Framework-free vs Framework

* **Vanilla JS** → examples above
* **React / Vue** → use `marked` or `react-markdown`

---

## ✅ Summary

✔ Use **marked.js** or **markdown-it**
✔ Fetch `.md` via HTTP
✔ Sanitize for user input
✔ Works in any modern browser

If you want:

* rendering **GitHub-style Markdown**
* **live editor preview**
* **React/Vue example**
* **offline/local file input**

Just tell me 👍
