ใน AWS จะมี **prefix ของชื่อ resource** หลายแบบที่เราเห็นบ่อย ๆ (เช่น `vpc-*`, `rtb-*`) ซึ่งจริง ๆ แล้วมันคือ **รหัสอัตโนมัติ (ID prefix)** ที่ AWS ใช้บอกชนิดของ resource นั้น ๆ
ด้านล่างคือสรุป **AWS Network / Infrastructure prefixes ที่พบบ่อย** พร้อมหน้าที่ของแต่ละตัว

---

## 1. Network หลัก (VPC & Connectivity)

### 🔹 `vpc-*` — **Virtual Private Cloud**

* เครือข่ายหลักของเราใน AWS
* ใช้กำหนด CIDR, subnet, route, security ต่าง ๆ
* เปรียบเหมือน Data Center ส่วนตัว

---

### 🔹 `subnet-*` — **Subnet**

* เครือข่ายย่อยภายใน VPC
* ผูกกับ Availability Zone (AZ)
* แบ่งเป็น:

  * Public Subnet
  * Private Subnet

---

### 🔹 `rtb-*` — **Route Table**

* กำหนดเส้นทางการรับส่ง traffic
* เช่น:

  * `0.0.0.0/0 → igw-*` (ออก Internet)
  * `0.0.0.0/0 → nat-*`

---

### 🔹 `igw-*` — **Internet Gateway**

* ทำให้ resource ใน VPC ออก Internet ได้
* ใช้กับ Public Subnet
* Attach ได้ทีละ 1 IGW ต่อ 1 VPC

---

### 🔹 `nat-*` — **NAT Gateway**

* ให้ Private Subnet ออก Internet ได้
* ขาเข้า Internet ไม่สามารถเข้ามาได้
* ใช้แทน NAT Instance (รุ่นเก่า)

---

### 🔹 `eni-*` — **Elastic Network Interface**

* Network card เสมือน
* มี IP, MAC, Security Group
* EC2 1 เครื่องมีหลาย ENI ได้

---

## 2. Security & Access Control

### 🔹 `sg-*` — **Security Group**

* Firewall ระดับ instance / ENI
* Stateful
* กำหนด:

  * Inbound
  * Outbound

---

### 🔹 `acl-*` — **Network ACL**

* Firewall ระดับ subnet
* Stateless
* ประมวลผลตาม rule number

---

## 3. Load Balancer & Traffic

### 🔹 `elb-*`

* Classic Load Balancer (เก่า)

### 🔹 `app/*` — **Application Load Balancer (ALB)**

* Layer 7 (HTTP/HTTPS)
* Routing ตาม path / host

### 🔹 `net/*` — **Network Load Balancer (NLB)**

* Layer 4 (TCP/UDP)
* Performance สูง, latency ต่ำ

---

## 4. Connectivity ระหว่าง Network

### 🔹 `pcx-*` — **VPC Peering Connection**

* เชื่อม VPC ↔ VPC
* ไม่มี transitive routing

---

### 🔹 `vgw-*` — **Virtual Private Gateway**

* ใช้กับ Site-to-Site VPN / Direct Connect
* อยู่ฝั่ง AWS

---

### 🔹 `cgw-*` — **Customer Gateway**

* ฝั่ง On-prem / Firewall
* ใช้คู่กับ VGW

---

### 🔹 `tgw-*` — **Transit Gateway**

* Hub กลางเชื่อมหลาย VPC / VPN / DX
* แก้ปัญหา VPC Peering ซับซ้อน

---

## 5. IP & DNS

### 🔹 `eipalloc-*` — **Elastic IP Allocation**

* Public IP แบบ Static
* ใช้กับ EC2 / NAT / NLB

---

### 🔹 `vpce-*` — **VPC Endpoint**

* เชื่อม AWS Service แบบไม่ผ่าน Internet
* เช่น S3, DynamoDB, Interface Endpoint

---

## 6. ตัวอย่างภาพรวมการใช้งาน

```
Internet
   |
 igw-*
   |
 public subnet (subnet-*)
   |
 private subnet (subnet-*)
   |
 nat-*
```

---

## 7. สรุปสั้น ๆ (จำง่าย)

| Prefix   | Resource         | หน้าที่หลัก                 |
| -------- | ---------------- | --------------------------- |
| vpc-*    | VPC              | เครือข่ายหลัก               |
| subnet-* | Subnet           | เครือข่ายย่อย               |
| rtb-*    | Route Table      | กำหนดเส้นทาง                |
| igw-*    | Internet Gateway | ออก Internet                |
| nat-*    | NAT Gateway      | Private subnet ออก Internet |
| sg-*     | Security Group   | Firewall ระดับ instance     |
| acl-*    | Network ACL      | Firewall ระดับ subnet       |
| eni-*    | ENI              | Network interface           |
| tgw-*    | Transit Gateway  | Hub network                 |

============

ได้เลยครับ 🙂
ด้านล่างคือ **Diagram สรุป AWS Network (VPC) แบบมาตรฐานที่ใช้จริงใน Production**

---

## 🗺️ AWS Network Diagram (พื้นฐาน + Best Practice)

```
                           🌐 Internet
                               |
                           ┌─────────┐
                           │  igw-*  │
                           │Internet │
                           │Gateway  │
                           └────┬────┘
                               
                ┌─────────────────────────────────┐
                │             vpc-*                │
                │        (10.0.0.0/16)              │
                │                                   │
                │   ┌──────────────┐   ┌──────────────┐
                │   │ Public Subnet │   │ Public Subnet │
                │   │ subnet-*      │   │ subnet-*      │
                │   │ 10.0.1.0/24   │   │ 10.0.2.0/24   │
                │   │               │   │               │
                │   │  EC2 / ALB    │   │  EC2 / ALB    │
                │   │  eipalloc-*   │   │               │
                │   └──────┬────────┘   └──────┬────────┘
                │          |                   |
                │       rtb-* (0.0.0.0/0 → igw-*)
                │          |
                │      ┌─────────┐
                │      │ nat-*   │  ← NAT Gateway
                │      └────┬────┘
                │           |
                │   ┌──────────────┐   ┌──────────────┐
                │   │ Private Subnet│   │ Private Subnet│
                │   │ subnet-*      │   │ subnet-*      │
                │   │ 10.0.11.0/24  │   │ 10.0.12.0/24  │
                │   │               │   │               │
                │   │ EC2 / ECS /   │   │ RDS / Cache   │
                │   │ EKS Node      │   │               │
                │   └──────┬────────┘   └──────┬────────┘
                │          |                   |
                │     rtb-* (0.0.0.0/0 → nat-*)
                │                                   │
                └─────────────────────────────────┘
```

---

## 🔐 Security Layer (ซ้อนอยู่ใน Diagram)

```
EC2 / ALB
   ├── sg-*  (Security Group - Stateful)
Subnet
   ├── acl-* (Network ACL - Stateless)
```

---

## 🔁 การเชื่อมต่อเพิ่มเติม (Optional)

### VPC ↔ VPC

```
vpc-* ─── pcx-* ─── vpc-*
```

### Hybrid (On-Prem)

```
On-Prem
   |
 cgw-*  ← Customer Gateway
   |
 vpn / dx
   |
 vgw-* หรือ tgw-*
   |
 vpc-*
```

---

## 🧠 Flow การใช้งานจริง (เข้าใจง่าย)

### 🌍 Inbound (ผู้ใช้เข้า Web)

```
Internet
 → igw-*
 → ALB (Public Subnet)
 → EC2 / ECS (Private Subnet)
```

### 🌐 Outbound (Server ออก Internet)

```
Private Subnet
 → nat-*
 → igw-*
 → Internet
```

---

## 📌 Prefix ที่เห็นใน Diagram นี้

| Prefix     | ความหมาย         |
| ---------- | ---------------- |
| vpc-*      | เครือข่ายหลัก    |
| subnet-*   | เครือข่ายย่อย    |
| igw-*      | Internet Gateway |
| nat-*      | NAT Gateway      |
| rtb-*      | Route Table      |
| sg-*       | Security Group   |
| acl-*      | Network ACL      |
| eipalloc-* | Elastic IP       |

---

ถ้าคุณอยากได้ต่อ:

* 🔧 **Diagram แบบ EKS / ECS / Microservice**
* 🔧 **Diagram Multi-AZ / High Availability**
* 🔧 **Diagram Transit Gateway (Enterprise scale)**
* 🔧 **ตัวอย่าง Naming Convention สำหรับ DevOps**

บอกมาได้เลยครับ จะจัดให้ตรงงาน Production 💪




