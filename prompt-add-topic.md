# Prompt Template: เพิ่ม Topic ใหม่ในเว็บไซต์

## Prompt สำหรับ AI / Copilot

เพิ่ม Topic ใหม่ให้กับเว็บไซต์ DevOps quick-command static site ตาม pattern ที่มีอยู่แล้ว

ข้อมูลพื้นฐาน:
- เว็บไซต์เป็น static HTML + Markdown
- Homepage ดึงข้อมูลจาก data/data.json
- แต่ละ topic มีไฟล์ .md และ .html render ด้วย Marked.js
- โครงสร้างไฟล์หลัก:
  - data/data.json
  - topic/<slug>.md
  - topic/<slug>.html
  - index.html

งานที่ต้องทำ:
1. เพิ่มข้อมูล topic ใหม่ใน data/data.json
2. สร้างไฟล์ Markdown สำหรับ topic ใหม่ใน folder topic/
3. สร้างไฟล์ HTML wrapper สำหรับ topic ใหม่ใน folder topic/
4. ตรวจสอบชื่อเรื่องและ description ให้สั้น กระชับและสอดคล้องกับเนื้อหา
5. เนื้อหาให้เป็นคำสั่งแบบ practical/quick reference สำหรับ DevOps หรือ Infra
6. ควรใช้รูปแบบ Markdown ที่เข้ากับเว็บเดิม เช่น heading, code block, note, separator
7. ตรวจสอบว่า topic สามารถเปิดจาก homepage ได้ และ URL ถูกต้อง

กรอกข้อมูลดังนี้:
- Topic Name: [TOPIC_NAME]
- Slug/filename: [topiс_slug]
- Description: [DESCRIPTION]
- เนื้อหา: [รายละเอียดหัวข้อ / คำสั่งที่ต้องการแนะนำ]
- Target audience: [DevOps / Infra / Kubernetes / Docker / Git / etc.]

### ตัวอย่าง prompt ที่ใช้ได้ทันที

```text
เพิ่ม Topic ใหม่ให้กับเว็บไซต์ DevOps quick-command static site

รายละเอียด:
- Topic Name: MicroK8s
- Slug: microk8s
- Description: คู่มือติดตั้งและใช้งาน MicroK8s สำหรับทดลอง Kubernetes บนเครื่อง local หรือ lab
- Target: Kubernetes / Local Lab

ข้อกำหนด:
- เพิ่ม entry ใหม่ใน data/data.json ตามรูปแบบ topic เดิม
- สร้างไฟล์ topic/microk8s.md ด้วยเนื้อหา Markdown แบบ practical command reference
- สร้างไฟล์ topic/microk8s.html เป็น wrapper ที่ fetch file .md แล้วแสดงผลด้วย Marked.js ตาม pattern ของ topic อื่น
- หัวข้อควรมีโครงสร้างดังนี้:
  1. หัวข้อหลัก
  2. การติดตั้ง
  3. การเปิดใช้งาน feature
  4. คำสั่งใช้งานหลัก
  5. ตัวอย่าง deploy / verify
  6. Troubleshooting / Note
- ใช้ภาษาไทยเป็นหลัก พร้อมคำสั่งภาษา shell
- ให้ code block เป็น ```sh
- ใช้ formatter ที่เข้ากับเว็บเดิม
- อย่าทำการแก้ไขโครงสร้างหลักของเว็บไซต์เกินจำเป็น
- ตรวจสอบว่า homepage card แสดง topic ใหม่และ link ไปหน้า topic ถูกต้อง

รูปแบบ data/data.json ที่ต้องใช้:
{
  "id": 9,
  "mylink": "microk8s.html",
  "title": "MicroK8s",
  "description": "คู่มือติดตั้งและใช้งาน MicroK8s สำหรับทดลอง Kubernetes บนเครื่อง local หรือ lab"
}

รูปแบบ topic/<slug>.html:
- ใช้ fetch("<slug>.md")
- innerHTML = marked.parse(text)
- ใช้ <a href="../index.html">กลับไปยังหน้าหลัก</a>
- ใช้ quick shell layout ที่มีอยู่แล้ว

ให้ทำงานเสร็จแบบครบถ้วน พร้อมไฟล์ที่จำเป็นและตรวจสอบผลลัพธ์จาก browser/local site ก่อนตอบกลับ
```

## Prompt แบบสั้นสำหรับการ reuse

```text
เพิ่ม topic ใหม่ให้กับเว็บไซต์ static DevOps quick-command ตามโครงสร้างเดิม

- เพิ่ม entry ใน data/data.json
- สร้างไฟล์ topic/[slug].md
- สร้างไฟล์ topic/[slug].html
- ใช้ pattern ของ topic อื่นใน repo
- เนื้อหาเป็น Markdown practical commands, ภาษาไทย + shell commands
- หัวข้อต้องสั้น กระชับ และเหมาะกับ homepage card
- ตรวจสอบ link จาก homepage เปิดได้และ render ถูกต้อง

ข้อมูล:
- Name: [TOPIC_NAME]
- Slug: [slug]
- Description: [description]
- Content focus: [focus area]
```

## Checklist ก่อนส่งงาน

- [ ] data/data.json มี entry ใหม่
- [ ] topic/[slug].md ถูกสร้าง
- [ ] topic/[slug].html ถูกสร้าง
- [ ] title และ description เหมาะกับ homepage
- [ ] Markdown ใช้ heading และ code block ถูกต้อง
- [ ] homepage card แสดงชื่อและ link ถูก
- [ ] เปิดหน้า topic ได้โดยไม่ error
- [ ] ไม่มีการแก้ไขไฟล์ที่ไม่เกี่ยวข้อง

## Suggested output format สำหรับ AI หลังทำงานเสร็จ

```text
เพิ่ม topic ใหม่เรียบร้อยแล้ว

ไฟล์ที่เปลี่ยน:
- data/data.json
- topic/[slug].md
- topic/[slug].html

ผลลัพธ์:
- homepage card แสดง topic ใหม่
- link ไปหน้า topic ถูกต้อง
- Markdown render ได้ตาม pattern

ตรวจสอบ:
- เปิดได้ที่ http://127.0.0.1:8000/
- หน้า topic โหลดสำเร็จ
```
