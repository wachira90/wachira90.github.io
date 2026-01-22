# Gitlab command create branch

```
- สร้าง branch "develop" โดยแตกออกจาก branch "main" 
- และ สร้าง branch "uat" โดยแตกออกจาก branch "develop" 
- และ สร้าง branch "production" โดยแตกออกจาก branch "uat" 
```

## **Git (local) และ push ไปที่ GitLab**

---

### สร้าง branch **develop** จาก **main**

### **ดึง branch ล่าสุดก่อน**

```sh
git fetch origin
```

### **Checkout ไปที่ main**

```sh
git checkout main
```

### **อัปเดต main ให้ล่าสุด**
```sh
git pull origin main
```
### **สร้างและสลับไปที่ develop**
```sh
git checkout -b develop
```
### **push develop ขึ้น GitLab**

```sh
git push -u origin develop
```

---

## 2️⃣ สร้าง branch 'uat' จาก 'develop'

``
# checkout ไปที่ develop
git checkout develop

# อัปเดต develop ให้ล่าสุด
git pull origin develop

# สร้างและสลับไปที่ uat
git checkout -b uat

# push uat ขึ้น GitLab
git push -u origin uat
``

---

## 3️⃣ สร้าง branch 'production' จาก 'uat'

``
# checkout ไปที่ uat
git checkout uat

# อัปเดต uat ให้ล่าสุด
git pull origin uat

# สร้างและสลับไปที่ production
git checkout -b production

# push production ขึ้น GitLab
git push -u origin production
``

---

## 🔎 ตรวจสอบ branch ทั้งหมด

``
git branch -a
``

---

### 📝 สรุปลำดับการแตก branch

``
main
└── develop
      └── uat
          └── production
``

=== 

## วิธีกำหนด protected branch uat และ production ไม่ให้ push ตรง แต่ให้ merg ระหว่าง branch ได้ 

ทำใน **GitLab UI** (เหมาะสุด เพราะ “ห้าม push ตรง” คุมได้ที่ server)

## วิธีตั้ง Protected Branch: 'uat' และ 'production'

1. เข้าโปรเจกต์ใน GitLab

2. ไปที่ **Settings → Repository**

3. เลื่อนหา section **Protected branches**

4. ที่ช่อง **Protect a branch** เลือก 'uat' แล้วกด **Protect**

5. ตั้งค่าแบบนี้:

  * **Allowed to push** = 'No one'
  * **Allowed to merge** = 'Maintainers' (หรือ 'Developers + Maintainers' ตามนโยบายทีม)

6. ทำซ้ำกับ branch 'production'

ผลลัพธ์:

* ❌ ไม่มีใคร 'git push' ตรงเข้า 'uat' / 'production' ได้
* ✅ ยัง merge เข้าได้ผ่าน Merge Request (MR) ตามสิทธิ์ที่กำหนด

---

## บังคับให้ “ต้องผ่าน Merge Request” (แนะนำทำเพิ่ม)

เพื่อให้ merge “ต้องเป็น MR เท่านั้น” และห้ามกด merge แบบมั่ว ๆ:

1. ไปที่ **Settings → Merge requests**
2. แนะนำเปิดตัวเลือกเหล่านี้:

  * ✅ **Merge method**: เลือกตามทีม (แนะนำ *Merge commit* หรือ *Squash*)
  * ✅ **Pipelines must succeed** (บังคับ CI ผ่านก่อน merge)
  * ✅ **All discussions must be resolved** (ต้อง resolve ก่อน)
  * ✅ **Prevent approval by author** (คนทำ MR ห้าม approve ตัวเอง)
  * ✅ ตั้ง **Approvals** (อย่างน้อย 1-2 คน)

---

## แนะนำเพิ่ม: ตั้ง “Push rules” กันการ push แบบหลุด policy

(ถ้า GitLab edition/สิทธิ์รองรับ)

* ไปที่ **Settings → Repository → Push rules**
* เช่น บังคับ message, ห้าม force push, หรือบังคับ commit sign ฯลฯ

---

## เช็คว่าได้ผลจริง

ลองจากเครื่อง dev:

``
git push origin uat
``

ควรโดน GitLab ปฏิเสธทันที (permission denied / not allowed)