# GitLab Merge & Protected Branches

คู่มือด่วนสำหรับสร้าง branch ตามลำดับ และบังคับให้ `uat` กับ `production` เปลี่ยนแปลงผ่าน Merge Request

```
สร้าง branch "develop" โดยแตกออกจาก branch "main" 
และ สร้าง branch "uat" โดยแตกออกจาก branch "develop" 
และ สร้าง branch "production" โดยแตกออกจาก branch "uat" 
```

**Git (local) และ push ไปที่ GitLab** 

---

## 1️⃣ สร้าง branch `develop` จาก `main`

```bash
# ดึง branch ล่าสุดก่อน
git fetch origin

# checkout ไปที่ main
git checkout main

# อัปเดต main ให้ล่าสุด
git pull origin main

# สร้างและสลับไปที่ develop
git checkout -b develop

# push develop ขึ้น GitLab
git push -u origin develop
```

---

## 2️⃣ สร้าง branch `uat` จาก `develop`

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

## 3️⃣ สร้าง branch `production` จาก `uat`

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

## Workflow ประจำวัน: แก้ไขและเปิด Merge Request

```bash
# เริ่มจาก branch ต้นทางที่อัปเดตแล้ว
git switch develop
git pull --ff-only origin develop

# สร้าง branch สำหรับงาน
git switch -c fix/timeout-config

# ตรวจสอบและบันทึกการเปลี่ยนแปลง
git status
git diff
git add path/to/file
git commit -m "แก้ค่า timeout ของ service"

# ส่ง branch ขึ้น GitLab
git push -u origin fix/timeout-config
```

จากนั้นเปิด Merge Request ไปยัง `develop` และตรวจ pipeline, review และไฟล์ที่เปลี่ยนแปลงก่อน merge

## ตรวจสอบความแตกต่างก่อน merge

```bash
# ดูว่า branch งานต่างจาก develop อย่างไร
git fetch origin
git diff origin/develop...HEAD

# ดู commit ที่มีเฉพาะใน branch งาน
git log --oneline origin/develop..HEAD
```

ถ้า branch ต้นทางมี commit ใหม่ ให้ sync ก่อนส่ง MR:

```bash
git switch fix/timeout-config
git rebase origin/develop
git push --force-with-lease
```

`--force-with-lease` ปลอดภัยกว่า `--force` เพราะ Git จะปฏิเสธเมื่อ remote มีการเปลี่ยนแปลงที่เราไม่เคย fetch มาก่อน

## Merge แบบ local และการแก้ conflict

```bash
git switch develop
git pull --ff-only origin develop
git merge --no-ff fix/timeout-config
```

เมื่อเกิด conflict ให้เปิดไฟล์ที่ Git แจ้ง แก้ส่วนที่มีเครื่องหมาย conflict แล้วรัน:

```bash
git status
git add path/to/resolved-file
git commit
```

ยกเลิก merge ที่ยังไม่เสร็จด้วย `git merge --abort` และตรวจ `git status` ทุกครั้งหลังแก้ conflict

## ยกเลิก commit หรือการ merge

```bash
# ยกเลิก commit ที่อยู่บน shared branch โดยสร้าง commit ใหม่
git revert <commit-sha>

# ยกเลิก merge ที่กำลังค้างอยู่ในเครื่อง
git merge --abort
```

หลีกเลี่ยง `git reset --hard` และ force push บน `main`, `uat` หรือ `production` เพราะอาจทำให้ commit ของผู้อื่นหายหรือทำให้ clone ของทีมตามประวัติไม่ทัน

---

### 📝 สรุปลำดับการแตก branch

```
main
 └── develop
      └── uat
           └── production
```

=== 

## วิธีกำหนด protected branch uat และ production ไม่ให้ push ตรง แต่ให้ merg ระหว่าง branch ได้ 

ทำใน **GitLab UI** (เหมาะสุด เพราะ “ห้าม push ตรง” คุมได้ที่ server)

## วิธีตั้ง Protected Branch: `uat` และ `production`

1. เข้าโปรเจกต์ใน GitLab

2. ไปที่ **Settings → Repository**

3. เลื่อนหา section **Protected branches**

4. ที่ช่อง **Protect a branch** เลือก `uat` แล้วกด **Protect**

5. ตั้งค่าแบบนี้:

   * **Allowed to push** = `No one`
   * **Allowed to merge** = `Maintainers` (หรือ `Developers + Maintainers` ตามนโยบายทีม)

6. ทำซ้ำกับ branch `production`

ผลลัพธ์:

* ❌ ไม่มีใคร `git push` ตรงเข้า `uat` / `production` ได้
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
