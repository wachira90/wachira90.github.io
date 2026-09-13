# คำถามที่พบบ่อยสำหรับ System Engineer

คำตอบสั้น ๆ สำหรับการใช้คำสั่ง การตรวจสอบระบบ และแนวทางทำงานที่ลดความเสี่ยงบน Production

## ควรเริ่มตรวจอะไรเมื่อระบบมีปัญหา?

เริ่มจากภาพรวมไปหารายละเอียด: ตรวจสถานะเครื่อง, CPU, Memory, Disk, network, service และ logs แล้วจึงเปลี่ยน configuration หรือ restart เท่าที่จำเป็น

## ควรดู Logs อย่างไรให้ได้ข้อมูลเร็ว?

กรองช่วงเวลาและคำสำคัญก่อน เช่น `journalctl -u nginx --since "10 min ago"` หรือ `kubectl logs -n develop deploy/api --since=10m` แล้วบันทึก error แรกที่พบไว้ใน incident timeline

## ควรใช้คำสั่งลบหรือ restart บน Production อย่างไร?

ยืนยัน environment, resource และผลกระทบก่อนรันทุกครั้ง ควรมี backup หรือ rollback plan และตรวจสถานะหลังดำเนินการเสมอ

## GitLab ควรป้องกัน branch ใด?

แนะนำป้องกัน `uat` และ `production` ไม่ให้ push ตรง ให้เปลี่ยนแปลงผ่าน Merge Request ที่ผ่าน review และ CI เท่านั้น

## เมื่อ SSH เข้าเครื่องไม่ได้ควรทำอย่างไร?

ใช้ console หรือ session สำรองตรวจ `systemctl status ssh`, firewall rules และ listen port ก่อนแก้ไข อย่าลบกฎ SSH เดิมจนกว่าจะยืนยันว่ากฎใหม่ใช้งานได้

## คำสั่งในเว็บนี้ปลอดภัยกับทุกระบบหรือไม่?

ไม่เสมอไป ชื่อ service, namespace, path, port และสิทธิ์แตกต่างกันตาม environment โปรดแทนค่า placeholder และทดลองใน development ก่อนใช้กับ Production
