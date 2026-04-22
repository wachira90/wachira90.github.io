Daily use command for DevOps & Infrastructure

---

## Basic Command


```sh
cat /dev/null > ~/.bash_history && history -c && exit

curl http://192.168.1.10 -H "Host: example.com"


```

## kubectl command

```sh
#RESTART

kubectl rollout -n develop restart deploy nginx

#SET-IMAGES

kubectl set image -n develop deploy exchange-api exchangeapi=registry.example.com/nginx:dev1

#EDIT-DEPLOYMENT

kubectl edit -n develop deploy exchange-api

#DESCRIBE

kubectl describe -n develop pod  $(kubectl get -n develop pod | awk '/^exchange-api-/ {print $1}')

#LOGS

kubectl logs -n develop  -f  $(kubectl get -n develop pod | awk '/^exchange-api-/ {print $1}')

#SHELL

kubectl exec -n develop --stdin --tty  $(kubectl get -n develop pod | awk '/^exchange-api-/ {print $1}') -- /bin/sh

kubectl exec -n develop --stdin --tty  $(kubectl get -n develop pod | awk '/^exchange-api-/ {print $1}') -- /bin/bash

#DELETE

kubectl delete -n develop pod $(kubectl get -n develop pod | awk '/^exchange-api-/ {print $1}')

#SCALE

kubectl scale -n develop deploy exchange-api --replicas=0

kubectl scale -n develop deploy exchange-api --replicas=1
```

## Basic Docker

```sh
docker run -itd --restart unless-stopped --name openai -p 8001:80  docker.io/wachira90/openai:getip-v1

docker ps 

docker ps -a



```

## alpine apk install package

```sh
apk update

apk add iputils-ping
apk add inetutils-telnet
apk add curl 
apk add busybox-extras
apk add openssh-client
apk add --no-cache openssh-client

apk search openssh

```