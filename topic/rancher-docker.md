# Rancher on Docker

Rancher เป็นเครื่องมือจัดการ Kubernetes แบบ UI-centric และสามารถติดตั้งบน Docker ได้ง่าย เหมาะสำหรับ lab, demo หรือการทดลองใช้งานก่อน deploy production

> ตัวอย่างด้านล่างใช้ Rancher Server รันบน Docker และมีคำสั่งสำหรับ join node เข้าสู่ cluster ที่สร้างจาก Rancher

---

## 1) ติดตั้ง Rancher Server บน Docker

### สร้าง Docker volume สำหรับข้อมูล Rancher

```bash
sudo docker volume create rancher-data
```

### เริ่มต้น Rancher Server

```bash
sudo docker run -d \
  --restart=unless-stopped \
  -p 80:80 \
  -p 443:443 \
  -v rancher-data:/var/lib/rancher \
  --name rancher \
  rancher/rancher:latest
```

### ตรวจสอบสถานะ container

```bash
sudo docker ps -a
sudo docker logs -f rancher
```

### ตรวจว่า Rancher พร้อมใช้งานหรือยัง

เมื่อ container เริ่มทำงานแล้ว ให้เปิด browser ไปที่:

```text
https://<IP-ADDRESS>
```

ถ้าใช้ local machine:

```text
https://127.0.0.1
```

> ครั้งแรก Rancher จะมีขั้นตอน setup admin password และสร้าง Kubernetes cluster หรือเข้าถึง UI

---

## 2) ตั้งค่าเริ่มต้น Rancher

1. เปิด Rancher UI
2. ตั้งค่า admin password
3. เลือก Create a Cluster หรือ Add Cluster
4. เลือกประเภท cluster ที่ต้องการ เช่น:
   - RKE
   - K3s
   - EKS / AKS / GKE
   - Custom
5. สำหรับ Custom Cluster ให้เลือกวิธี add node

---

## 3) คำสั่ง join node แบบ Custom Cluster

Rancher จะแสดงคำสั่งให้ join node โดยมี URL, token และ checksum เป็นข้อมูลแยกแต่ละ node

### รูปแบบคำสั่งทั่วไป

```bash
sudo docker run -d \
  --privileged \
  --restart=unless-stopped \
  --net=host \
  -v /etc/kubernetes:/etc/kubernetes \
  -v /var/run:/var/run \
  rancher/rancher-agent:v2.8.4 \
  --server https://<RANCHER_HOST> \
  --token <TOKEN> \
  --ca-checksum <CA_CHECKSUM> \
  --etcd \
  --controlplane \
  --worker
```

### ตัวอย่างจริง

```bash
sudo docker run -d \
  --privileged \
  --restart=unless-stopped \
  --net=host \
  -v /etc/kubernetes:/etc/kubernetes \
  -v /var/run:/var/run \
  rancher/rancher-agent:v2.8.4 \
  --server https://rancher.example.com \
  --token token-abcde:xyz123 \
  --ca-checksum 7c4b3ef2b1a8d2d2c9f9f93ce39d9d0f5b555a1d \
  --worker
```

### ถ้าเป็น worker node อย่างเดียว

```bash
sudo docker run -d \
  --privileged \
  --restart=unless-stopped \
  --net=host \
  -v /etc/kubernetes:/etc/kubernetes \
  -v /var/run:/var/run \
  rancher/rancher-agent:v2.8.4 \
  --server https://rancher.example.com \
  --token token-abcde:xyz123 \
  --ca-checksum 7c4b3ef2b1a8d2d2c9f9f93ce39d9d0f5b555a1d \
  --worker
```

### ถ้าเป็น control plane + etcd + worker

```bash
sudo docker run -d \
  --privileged \
  --restart=unless-stopped \
  --net=host \
  -v /etc/kubernetes:/etc/kubernetes \
  -v /var/run:/var/run \
  rancher/rancher-agent:v2.8.4 \
  --server https://rancher.example.com \
  --token token-abcde:xyz123 \
  --ca-checksum 7c4b3ef2b1a8d2d2c9f9f93ce39d9d0f5b555a1d \
  --etcd \
  --controlplane \
  --worker
```

---

## 4) ตรวจสอบ node ที่ join แล้ว

หลังรันคำสั่ง join node ให้ทำตรวจสอบใน Rancher UI หรือบนเครื่อง node:

```bash
sudo docker ps -a
sudo docker logs -f $(sudo docker ps -q --filter name=rancher-agent)
```

จากเครื่องที่เข้าร่วม cluster:

```bash
kubectl get nodes
kubectl get pods -A
```

ถ้า node ยังไม่เห็น ให้รอซักครู่แล้วตรวจอีกครั้ง:

```bash
kubectl get nodes -o wide
```

---

## 5) ตัวอย่างคำสั่งสำหรับ Linux node

```bash
sudo apt update
sudo apt install -y curl docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

หลังจากนั้นคัดลอกคำสั่ง join จาก Rancher UI ไปรันบน node นั้น ๆ

---

## 6) ถ้าต้องการลบ Rancher Container

```bash
sudo docker stop rancher
sudo docker rm rancher
sudo docker volume rm rancher-data
```

---

## 7) Quick Reference

```bash
sudo docker volume create rancher-data
sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 -v rancher-data:/var/lib/rancher --name rancher rancher/rancher:latest
sudo docker logs -f rancher

sudo docker run -d \
  --privileged \
  --restart=unless-stopped \
  --net=host \
  -v /etc/kubernetes:/etc/kubernetes \
  -v /var/run:/var/run \
  rancher/rancher-agent:v2.8.4 \
  --server https://rancher.example.com \
  --token <TOKEN> \
  --ca-checksum <CHECKSUM> \
  --worker
```

---

## 8) Tips

- Rancher Server ควรติดตั้งบน VM หรือ server ที่มี IP คงที่และเปิด port 80/443
- ควรใช้ TLS certificate ที่ถูกต้องจริง หรือ reverse proxy/Let's Encrypt
- สำหรับ lab ควรใช้ node 2-3 เครื่องเพื่อทดลอง HA หรือ control plane
- หาก join node ไม่สำเร็จ ให้ตรวจว่า:
  - Docker service ทำงาน
  - ไม่มี firewall ปิด port ที่ Rancher ต้องใช้
  - token / checksum ถูกต้อง
  - node มี DNS ที่สามารถเข้าถึง Rancher ได้

---

## สรุป

คำสั่งหลักที่ใช้บ่อยที่สุดคือ:

1. รัน Rancher Server บน Docker
2. เปิด Rancher UI และสร้าง Cluster
3. Copy คำสั่ง join node จาก Rancher UI
4. รันคำสั่ง join node บน worker / control plane node
5. ตรวจสอบด้วย `kubectl get nodes`

วิธีนี้เหมาะมากสำหรับ ศึกษา Kubernetes, lab, proof of concept และใช้งานแบบไม่ซับซ้อนก่อน deploy จริง
