# GitLab Branch Workflow

ขั้นตอนด่วนสำหรับสร้างสายงาน `main → develop → uat → production` และเผยแพร่ branch ไปยัง GitLab อย่างเป็นลำดับ

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

```bash
# checkout ไปที่ develop
git checkout develop

# อัปเดต develop ให้ล่าสุด
git pull origin develop

# สร้างและสลับไปที่ uat
git checkout -b uat

# push uat ขึ้น GitLab
git push -u origin uat
```

---

## 3️⃣ สร้าง branch 'production' จาก 'uat'

```bash
# checkout ไปที่ uat
git checkout uat

# อัปเดต uat ให้ล่าสุด
git pull origin uat

# สร้างและสลับไปที่ production
git checkout -b production

# push production ขึ้น GitLab
git push -u origin production
```

---

## 🔎 ตรวจสอบ branch ทั้งหมด

```bash
git branch -a
```

## คำสั่ง Git ที่ใช้ประจำ

### ตรวจสอบสถานะและประวัติ

```bash
# ดูไฟล์ที่แก้ไข ไฟล์ที่รอ commit และ branch ปัจจุบัน
git status

# ดูประวัติแบบอ่านง่าย
git log --oneline --decorate --graph --all

# ดูรายละเอียดการเปลี่ยนแปลงที่ยังไม่ stage
git diff

# ดูรายละเอียดที่ stage แล้ว
git diff --staged
```

### สร้าง commit และส่งขึ้น remote

```bash
# เพิ่มไฟล์ที่ต้องการเข้า staging area
git add path/to/file

# เพิ่มทุกไฟล์ที่แก้ไขในโฟลเดอร์ปัจจุบัน
git add .

# สร้าง commit ที่อธิบายการเปลี่ยนแปลงให้ชัดเจน
git commit -m "เพิ่ม health check สำหรับ service"

# ส่ง branch ปัจจุบันขึ้น remote หลังตั้ง upstream แล้ว
git push
```

ก่อน `git add .` ควรตรวจ `git status` และไม่ควร commit secret, `.env`, private key หรือไฟล์ build ที่ไม่จำเป็น

### สร้าง branch งานใหม่จาก branch ล่าสุด

```bash
git switch develop
git pull --ff-only origin develop
git switch -c feature/health-check
```

ใช้ชื่อ branch ที่สื่อความหมาย เช่น `feature/...`, `fix/...` หรือ `hotfix/...` และทำงานบน branch ของตัวเองแทนการแก้ `main`, `uat` หรือ `production` โดยตรง

### อัปเดต branch งานให้ตามต้นทาง

```bash
git fetch origin
git switch feature/health-check
git rebase origin/develop
```

ถ้าเกิด conflict ให้แก้ไฟล์ แล้วตรวจและทำต่อ:

```bash
git status
git add path/to/resolved-file
git rebase --continue
```

ยกเลิก rebase ที่กำลังทำอยู่ด้วย `git rebase --abort` หากยังไม่พร้อมแก้ conflict

### เก็บงานชั่วคราวด้วย stash

```bash
git stash push -m "งาน health check ชั่วคราว"
git switch develop
git pull --ff-only origin develop
git switch feature/health-check
git stash pop
```

ตรวจรายการ stash ด้วย `git stash list` และอย่าใช้ `git stash pop` ถ้ายังไม่ได้ตรวจว่า branch ปลายทางไม่มีการเปลี่ยนแปลงที่ชนกัน

### ยกเลิกการเปลี่ยนแปลงอย่างปลอดภัย

```bash
# ยกเลิกการแก้ไขในไฟล์ที่ยังไม่ได้ stage
git restore path/to/file

# นำไฟล์ออกจาก staging แต่เก็บการแก้ไขไว้
git restore --staged path/to/file

# สร้าง commit ใหม่เพื่อยกเลิก commit เดิม เหมาะกับ shared branch
git revert <commit-sha>
```

`git restore` อาจทำให้การแก้ไขที่ยังไม่ commit หายไป ส่วน `git revert` ปลอดภัยกว่าสำหรับ branch ที่แชร์กับทีม เพราะไม่แก้ประวัติเดิม

---

### 📝 สรุปลำดับการแตก branch

```text
main
└── develop
      └── uat
          └── production
```

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

```bash
git push origin uat
```

ควรโดน GitLab ปฏิเสธทันที (permission denied / not allowed)