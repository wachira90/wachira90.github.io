นี่คือโครงร่างเนื้อหาสำหรับนำไปใช้สอนเรื่อง **Docker Stack** พร้อมกับ Workshop ที่เน้นการนำไปใช้งานจริงในระดับ Production โดยใช้ตัวอย่างของระบบ Monitoring ซึ่งเป็นส่วนสำคัญของงาน Infrastructure ครับ

---

## ส่วนที่ 1: เนื้อหาภาคทฤษฎี (Theory)

### 1. Docker Stack คืออะไร?

* เครื่องมือสำหรับ Deploy และจัดการกลุ่มของ Container (Services) หลายๆ ตัวให้ทำงานร่วมกัน
* ออกแบบมาสำหรับการรันบน **Docker Swarm Mode** (Production Environment)
* ใช้ไฟล์นามสกุล `.yml` (YAML) ในการคอนฟิก ซึ่งคล้ายกับ Docker Compose

### 2. ความแตกต่างระหว่าง Docker Compose และ Docker Stack

**Docker Compose:**

* เหมาะสำหรับ Development / Testing
* รันบนเครื่องเดียว (Single Host)
* คำสั่งพื้นฐาน: `docker-compose up`

**Docker Stack:**

* เหมาะสำหรับ Production
* รันแบบ Cluster ผ่าน Docker Swarm (Multiple Hosts / Nodes)
* รองรับฟีเจอร์ Deploy เช่น Replicas, Update Configuration, Rollback
* คำสั่งพื้นฐาน: `docker stack deploy`

### 3. โครงสร้างของไฟล์ docker-compose.yml สำหรับ Stack

* **Version:** ต้องใช้เวอร์ชัน 3.0 ขึ้นไป (แนะนำ 3.8 หรือ 3.9)
* **Services:** กำหนด Image, Ports, Volumes ของแต่ละ Container
* **Deploy:** เป็น Section พิเศษสำหรับ Stack เพื่อกำหนดจำนวน Replicas, ข้อจำกัดของ Node (Constraints), และเงื่อนไขการ Restart
* **Networks:** กำหนด Overlay Network ให้ Service ข้าม Node คุยกันได้

---

## ส่วนที่ 2: Workshop - Deploying a Monitoring Stack

Workshop นี้จะเป็นการจำลองการ Deploy ระบบ Monitoring พื้นฐานที่ประกอบด้วย **Prometheus** และ **Grafana** ผ่าน Docker Stack

### ข้อกำหนดเบื้องต้น (Prerequisites)

1. มีเครื่อง Linux (เช่น Ubuntu 24.04) ที่ติดตั้ง Docker Engine แล้ว
2. สิทธิ์การใช้งานระดับ Root หรือ Sudo

### ขั้นตอนที่ 1: เปิดใช้งาน Docker Swarm Mode

Docker Stack จำเป็นต้องทำงานบน Swarm Mode เสมอ เริ่มต้นด้วยการเปลี่ยน Docker Host ให้เป็น Swarm Manager

```bash
docker swarm init

#หากต้องการออกจาก swarm
docker swarm leave --force
```

*หากรันสำเร็จ ระบบจะแสดง Token สำหรับให้ Worker Node เครื่องอื่นเข้ามาร่วม Cluster*

*การ join node อ่านได้ที่*

### ขั้นตอนที่ 2: สร้างไฟล์ Configuration

สร้างไดเรกทอรีสำหรับ Workshop และสร้างไฟล์ YAML

```bash
mkdir monitoring-stack
cd monitoring-stack
nano docker-compose.yml

```

คัดลอกโค้ดด้านล่างไปวางในไฟล์ `docker-compose.yml`

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    deploy:
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: any

```

### ขั้นตอนที่ 3: สั่ง Deploy Docker Stack

ใช้คำสั่ง `deploy` โดยระบุชื่อไฟล์และตั้งชื่อ Stack นี้ว่า `mon_stack`

```bash
docker stack deploy -c docker-compose.yml mon_stack

```

### ขั้นตอนที่ 4: ตรวจสอบสถานะการทำงาน

คำสั่งสำหรับการตรวจสอบและดูภาพรวมของ Stack ที่กำลังรันอยู่

* **ดูรายชื่อ Stack ทั้งหมด:**
```bash
docker stack ls

```


* **ดูรายชื่อ Service ย่อยภายใน Stack:**
```bash
docker stack services mon_stack

```


* **ดูสถานะของ Container (Tasks) แต่ละตัว:**
```bash
docker stack ps mon_stack

```



### ขั้นตอนที่ 5: ทดสอบการเข้าใช้งาน

* เปิด Web Browser ไปที่ `http://<IP_ของเครื่อง>:9090` เพื่อดูหน้าต่างของ Prometheus
* เปิด Web Browser ไปที่ `http://<IP_ของเครื่อง>:3000` เพื่อดูหน้าต่างของ Grafana (User/Pass เริ่มต้นคือ admin/admin)

### ขั้นตอนที่ 6: การลบ Stack (Clean up)

เมื่อจบคลาสสอน หรือต้องการลบระบบทิ้งทั้งหมด สามารถใช้คำสั่งลบ Stack ได้เพียงคำสั่งเดียว

```bash
docker stack rm mon_stack

```

*ระบบจะทำการไล่ลบ Service, Network และ Container ที่เกี่ยวข้องกับ Stack นี้ออกทั้งหมดโดยอัตโนมัติ*

## อธิบาย 

โค้ดชุดนี้คือการตั้งค่าไฟล์ `docker-compose.yml` สำหรับนำไปรันบน **Docker Swarm** ผ่านคำสั่ง `docker stack deploy` โดยแบ่งการอธิบายออกเป็นส่วนๆ ดังนี้ครับ:

### ภาพรวมและการตั้งค่าพื้นฐาน

* **`version: '3.8'`**: ระบุเวอร์ชันของ Syntax ที่ใช้ ซึ่งเวอร์ชัน 3.x ขึ้นไป ถูกออกแบบมาเพื่อให้รองรับการทำงานร่วมกับ Docker Swarm (Docker Stack) ได้อย่างสมบูรณ์
* **`services:`**: บล็อกสำหรับประกาศว่าในระบบ (Stack) นี้จะมี Container อะไรทำงานอยู่บ้าง ซึ่งในที่นี้มี 2 ตัวคือ `prometheus` และ `grafana`

---

### Service: Prometheus

```yaml
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"

```

* **`image` และ `ports**`: เป็นการดึงอิมเมจ `prometheus:latest` มาใช้งาน และจับคู่พอร์ต 9090 ของเครื่อง Host เข้ากับพอร์ต 9090 ของ Container เพื่อให้เราเรียกดูหน้าเว็บได้

```yaml
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure

```

บล็อก **`deploy:`** คือหัวใจสำคัญของการทำ Docker Stack ซึ่งจะทำงานเมื่ออยู่บน Swarm Mode เท่านั้น:

* **`replicas: 1`**: กำหนดให้รัน Prometheus เพียงแค่ 1 Container (Task) ใน Cluster
* **`placement: constraints: [node.role == manager]`**:  เป็นการบังคับ (Constraint) ว่า Container ตัวนี้ **จะต้องถูกนำไปรันบน Node ที่ทำหน้าที่เป็น "Manager" เท่านั้น** ห้ามไปรันบน Worker Node เด็ดขาด (มักใช้กับ Service ที่ต้องการเข้าถึงข้อมูลหรือสถานะระดับคลัสเตอร์โดยตรง หรือผูกติดกับ Volume ที่อยู่บน Manager)
* **`restart_policy: condition: on-failure`**: หาก Container นี้หยุดทำงานลงแบบผิดปกติ (Exit Code ไม่ใช่ 0) ระบบ Swarm จะพยายาม Restart ให้ใหม่โดยอัตโนมัติ

---

### Service: Grafana

```yaml
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"

```

* เหมือนกับตัวบน คือใช้ Grafana อิมเมจล่าสุด และเปิดให้เข้าถึงผ่านพอร์ต 3000 ของเครื่อง Host

```yaml
    deploy:
      replicas: 1
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: any

```

* **`update_config:`**: เป็นการกำหนดพฤติกรรมเมื่อมีการสั่ง **Rolling Update** (เช่น การเปลี่ยนเวอร์ชันอิมเมจจาก 1.0 เป็น 2.0 ในอนาคต)
* **`parallelism: 1`**: ให้อัปเดตและสั่งรัน Container ตัวใหม่ทีละ 1 ตัว
* **`delay: 10s`**: หน่วงเวลา 10 วินาที ก่อนที่จะดำเนินการอัปเดต Container ตัวถัดไป (แม้ปัจจุบันจะมีแค่ 1 Replica แต่การใส่ไว้คือ Best Practice เพื่อให้ระบบทำงานแบบ Zero-Downtime ได้อย่างราบรื่นหากมีการ Scale จำนวน Replicas เพิ่มขึ้นในอนาคต)


* **`restart_policy: condition: any`**: ไม่ว่า Grafana จะหยุดทำงานด้วยสาเหตุใดก็ตาม (ทั้งแบบปกติ หรือแบบพัง) ระบบจะทำการ Restart ใหม่ให้เสมอ เพื่อให้แน่ใจว่า Service จะพร้อมทำงานตลอดเวลา


# การเพิ่ม (Join) เครื่อง หรือ Node 

การเพิ่ม (Join) เครื่องหรือ Node ใหม่เข้าไปในระบบคลัสเตอร์ของ Docker นั้น จะเป็นกระบวนการของ **Docker Swarm** (ส่วน Docker Stack คือคำสั่งที่ใช้ในการ Deploy แอปพลิเคชันลงบน Swarm อีกที)

เพื่อให้เห็นภาพรวมของระบบ Manager และ Worker ใน Docker Swarm ได้ชัดเจนขึ้น สามารถดูแผนภาพด้านล่างนี้ประกอบได้

ขั้นตอนและตัวอย่างคำสั่งในการนำ Node ใหม่เข้าร่วม (Join) Docker Swarm 

### ขั้นตอนที่ 1: ขอ Token จาก Manager Node

คุณต้องดึง "Join Token" จากเครื่องที่ทำหน้าที่เป็น **Manager Node** ก่อน เพื่อให้เครื่องใหม่ใช้เป็นกุญแจในการเข้าร่วม โดยให้คุณล็อกอินเข้าเครื่อง Manager แล้วรันคำสั่งใดคำสั่งหนึ่ง ดังนี้:

**หากต้องการให้เครื่องใหม่เป็น Worker Node (ใช้รันแอปพลิเคชันอย่างเดียว):**

```bash
docker swarm join-token worker

```

**หากต้องการให้เครื่องใหม่เป็น Manager Node (ใช้บริหารจัดการคลัสเตอร์ด้วย):**

```bash
docker swarm join-token manager

```

เมื่อรันคำสั่ง ระบบจะแสดงผลลัพธ์ (Output) กลับมาเป็นคำสั่งที่พร้อมใช้งาน ตัวอย่างเช่น:

> `To add a worker to this swarm, run the following command:`
> `docker swarm join --token SWMTKN-1-49nj1cmql0jkz5s954yi3oex3nedyz0fb0xx14ie39trti4wxv-8vxv8rssqyt6cw0dbjxcq03x2 192.168.99.100:2377`

---

### ขั้นตอนที่ 2: รันคำสั่ง Join บนเครื่องใหม่ (Node ที่ต้องการเพิ่ม)

ให้คุณคัดลอกคำสั่งที่ได้จากขั้นตอนแรก ไปวางและรันใน Terminal ของ **เครื่องใหม่** ที่ต้องการนำมาเข้าร่วมคลัสเตอร์

```bash
docker swarm join --token SWMTKN-1-49nj1cmql0jkz5s954yi3oex3nedyz0fb0xx14ie39trti4wxv-8vxv8rssqyt6cw0dbjxcq03x2 192.168.99.100:2377

```

หากสำเร็จ ระบบจะแสดงข้อความว่า:

> `This node joined a swarm as a worker.`

*(หมายเหตุ: `192.168.99.100` คือ IP ของ Manager Node และ `2377` คือ Port มาตรฐานที่ Docker Swarm ใช้สื่อสารกัน)*

---

### ขั้นตอนที่ 3: ตรวจสอบความสำเร็จ (ทำบน Manager Node)

กลับมาที่เครื่อง Manager Node เพื่อตรวจสอบว่า Node ใหม่ได้ถูกเพิ่มเข้ามาในระบบเรียบร้อยแล้วหรือไม่ โดยรันคำสั่ง:

```bash
docker node ls

```
คุณจะเห็นตารางแสดงรายชื่อ Node ทั้งหมดในระบบ พร้อมสถานะ (Status) เป็น `Ready` และ Availability เป็น `Active` แสดงว่า Node ใหม่พร้อมรับคำสั่งจาก Docker Stack เพื่อ Deploy แอปพลิเคชัน

## Port Require

Node ใหม่จะสามารถเชื่อมต่อและทำงานร่วมกับ Manager Node ใน Docker Swarm ได้อย่างสมบูรณ์ คุณจำเป็นต้องเปิด Port ที่เกี่ยวข้องใน Firewall (หรือ Security Group หากใช้ระบบ Cloud) ระหว่างเครื่องในคลัสเตอร์ดังต่อไปนี้:

* **Port 2377 (TCP):** ใช้สำหรับจัดการคลัสเตอร์ (Cluster Management Communications)
* *หน้าที่:* เป็น Port หลักที่เครื่อง Manager ใช้สื่อสาร แจกจ่ายงาน และรับข้อมูลจากเครื่อง Worker


* **Port 7946 (TCP และ UDP):** ใช้สำหรับการสื่อสารระหว่าง Node (Node-to-node Communication)
* *หน้าที่:* ใช้เพื่อให้แต่ละเครื่องในคลัสเตอร์มองเห็นและค้นหากันเองได้ รวมถึงการเช็คสถานะ (Health check/Gossip) ของเครื่องอื่นๆ


* **Port 4789 (UDP):** ใช้สำหรับระบบเครือข่ายจำลอง (Overlay Network Traffic)
* *หน้าที่:* สำคัญมากเพื่อให้ Container ที่รันอยู่คนละเครื่อง (Node) สามารถส่งข้อมูลสื่อสารหากันได้ผ่านเครือข่ายภายในของ Docker (Ingress Network)



> **ข้อควรระวัง:** หากเปิดเพียง Port 2377 เครื่องใหม่อาจจะพิมพ์คำสั่ง Join ได้สำเร็จและมองเห็นในระบบ แต่เมื่อคุณสั่ง Deploy แอปพลิเคชันด้วย Docker Stack แล้ว Container ที่อยู่คนละเครื่องจะไม่สามารถสื่อสารกันได้เลยหากลืมเปิด Port 7946 และ 4789
