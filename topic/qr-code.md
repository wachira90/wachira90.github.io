Here’s a **simple QRCode.js CDN example in plain HTML** you can copy & run immediately.

---

## ✅ Basic QR Code (CDN + HTML)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>QR Code Example</title>

  <!-- QRCode.js CDN -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
</head>
<body>

  <h2>QR Code Example</h2>

  <!-- Container -->
  <div id="qrcode"></div>

  <script>
    // Generate QR Code
    var qrcode = new QRCode(document.getElementById("qrcode"), {
      text: "https://example.com",
      width: 200,
      height: 200,
      colorDark: "#000000",
      colorLight: "#ffffff",
      correctLevel: QRCode.CorrectLevel.H
    });
  </script>

</body>
</html>
```

---

## 🔹 How it works

* The CDN loads **QRCode.js** (no install needed) ([cdnjs][1])
* You create a container (`div id="qrcode"`)
* Then initialize:

  ```js
  new QRCode(element, options)
  ```
* It renders QR as canvas/table automatically ([GeeksforGeeks][2])

---

## ⚡ Minimal version (shortest possible)

```html
<div id="qrcode"></div>
<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
<script>
  new QRCode("qrcode", "Hello World");
</script>
```

---

## 🔥 Bonus: Dynamic input example

```html
<input type="text" id="text" placeholder="Enter text">
<button onclick="generate()">Generate</button>

<div id="qrcode"></div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>

<script>
  var qr;

  function generate() {
    var value = document.getElementById("text").value;

    if (!qr) {
      qr = new QRCode("qrcode", value);
    } else {
      qr.makeCode(value); // update QR
    }
  }
</script>
```

---

If you want, I can show:

* QR code with logo in center
* Download QR as PNG
* React / Vue version

Just tell me 👍

[1]: https://cdnjs.com/libraries/qrcodejs?utm_source=chatgpt.com "qrcodejs - Libraries - cdnjs - The #1 free and open source CDN built to ..."
[2]: https://www.geeksforgeeks.org/javascript/how-to-make-a-qr-code-generator-using-qrcode-js/?utm_source=chatgpt.com "How to make a QR Code generator using qrcode.js - GeeksforGeeks"
