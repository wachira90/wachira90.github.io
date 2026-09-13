# MicroK8s Installation & Usage

MicroK8s เป็น Kubernetes package แบบ lightweight สำหรับ Linux, Windows และ macOS ที่ติดตั้งง่ายและใช้งานได้เร็ว เหมาะสำหรับการทดลองหรือ lab ที่ต้องการ Kubernetes แบบสั้น ๆ

> คำแนะนำ: สำหรับระบบ Production ควรใช้แพลตฟอร์มที่ออกแบบมาสำหรับ HA และ security อย่างเข้มข้นกว่า MicroK8s

---

## 1) ติดตั้งบน Ubuntu / Debian

```bash
sudo apt update
sudo apt install -y snapd
sudo snap install microk8s --classic
```

หลังติดตั้ง ให้รอให้ MicroK8s เริ่มทำงานและตรวจสถานะ:

```bash
microk8s status --wait-ready
```

ถ้าเป็น user ทั่วไป ให้ใช้คำสั่งนี้เพื่อเข้าถึง CLI:

```bash
sudo usermod -a -G microk8s $USER
newgrp microk8s
```

หรือใช้งานแบบไม่ต้อง sudo:

```bash
alias kubectl='microk8s kubectl'
```

---

## 2) เปิดใช้งาน Add-ons ที่จำเป็น

MicroK8s มี add-ons สำหรับ DNS, storage, ingress และ dashboard เรียบร้อยแล้ว

```bash
microk8s enable dns storage ingress dashboard
```

ถ้าต้องการตรวจรายการ add-ons:

```bash
microk8s status
microk8s enable --help
```

### ตัวอย่าง Add-ons ที่ใช้บ่อย

```bash
microk8s enable dashboard
microk8s enable registry
microk8s enable hostpath-storage
microk8s enable ingress
```

---

## 3) ใช้งาน kubectl กับ MicroK8s

### วิธีที่ 1: ใช้ผ่าน microk8s kubectl

```bash
microk8s kubectl get nodes
microk8s kubectl get pods -A
```

### วิธีที่ 2: ตั้ง alias

```bash
alias kubectl='microk8s kubectl'
kubectl get nodes
kubectl get pods -A
```

### วิธีที่ 3: ใช้ kubeconfig ของ MicroK8s

```bash
microk8s config > ~/.kube/config
kubectl get nodes
```

---

## 4) ตรวจสอบ Cluster

```bash
microk8s kubectl get nodes
microk8s kubectl get pods -A
microk8s kubectl get ns
microk8s kubectl cluster-info
```

ตรวจสถานะ pod แบบละเอียด:

```bash
microk8s kubectl describe pod <pod-name> -n <namespace>
```

ดู log:

```bash
microk8s kubectl logs -f <pod-name> -n <namespace>
```

---

## 5) Deploy Application ทดสอบ

### สร้าง Namespace

```bash
microk8s kubectl create namespace demo
```

### Deploy nginx ทดสอบ

```bash
microk8s kubectl create deployment nginx-demo --image=nginx -n demo
microk8s kubectl expose deployment nginx-demo --port=80 --type=NodePort -n demo
microk8s kubectl get pods -n demo
microk8s kubectl get svc -n demo
```

### ตรวจ port ที่เปิด

```bash
microk8s kubectl get svc -n demo -o wide
```

### Port-forward สำหรับทดสอบ local

```bash
microk8s kubectl port-forward -n demo svc/nginx-demo 8080:80
```

จากนั้นเปิดใน browser:

```text
http://127.0.0.1:8080
```

---

## 6) Deploy YAML Manifest

```bash
cat <<'EOF' > nginx-demo.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
  namespace: demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-demo
  namespace: demo
spec:
  selector:
    app: nginx-demo
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
  type: NodePort
EOF

microk8s kubectl apply -f nginx-demo.yaml
```

---

## 7) Common Operations

### Scale deployment

```bash
microk8s kubectl scale deployment nginx-demo --replicas=3 -n demo
```

### Delete deployment

```bash
microk8s kubectl delete deployment nginx-demo -n demo
microk8s kubectl delete svc nginx-demo -n demo
```

### ดูงานทั้งหมด

```bash
microk8s kubectl get all -A
```

### ดู YAML ของ resource

```bash
microk8s kubectl get deployment nginx-demo -n demo -o yaml
```

---

## 8) คำสั่งตั้งค่าและ troubleshooting

### รีสตาร์ท MicroK8s

```bash
sudo systemctl restart snap.microk8s.daemon-kubelet
sudo systemctl restart snap.microk8s.daemon-apiserver
```

### ตรวจเลข version

```bash
microk8s version
microk8s kubectl version
```

### ตรวจว่ามี add-ons ไหนเปิดอยู่

```bash
microk8s status
```

### ถ้าคลัสเตอร์ไม่พร้อม

```bash
journalctl -u snap.microk8s.daemon-apiserver -n 100 --no-pager
journalctl -u snap.microk8s.daemon-kubelet -n 100 --no-pager
```

---

## 9) Tips สำหรับการใช้งานจริง

- ใช้ `microk8s kubectl` หรือ alias `kubectl='microk8s kubectl'` เพื่อให้สั้นลง
- เปิด add-ons ตามความจำเป็น เช่น `dns`, `storage`, `ingress`
- ควรใช้งาน `namespace` แยกตาม service หรือ environment เช่น `dev`, `staging`, `prod`
- เพิ่ม metrics / dashboard เมื่อต้องการ monitor
- ถ้ารันบน VM หรือ laptop ควรตั้ง resource ให้เพียงพอ เช่น RAM และ CPU

---

## 10) ล้าง/ยกเลิกการติดตั้ง

```bash
sudo snap remove microk8s
```

หากต้องการลบข้อมูล local config:

```bash
rm -rf ~/.kube
```

---

## Quick Reference

```bash
microk8s status --wait-ready
microk8s enable dns storage ingress
microk8s kubectl get nodes
microk8s kubectl get pods -A
microk8s kubectl create deployment nginx-demo --image=nginx -n demo
microk8s kubectl expose deployment nginx-demo --port=80 --type=NodePort -n demo
microk8s kubectl logs -f <pod-name> -n demo
microk8s kubectl delete pod <pod-name> -n demo
```

---

## สรุป

MicroK8s เหมาะสำหรับ:

- การเรียนรู้ Kubernetes
- ทดลอง deploy service ในเครื่อง local
- ทดสอบ Helm / manifest / CI pipeline ก่อน deploy จริง
- ลองใช้ add-ons ต่าง ๆ อย่างรวดเร็ว

หากต้องการใช้ใน Production จริง ควรใช้ Kubernetes ที่มีเครื่องมือ ops, backup, monitoring และ cluster management ที่ครบถ้วนกว่า
