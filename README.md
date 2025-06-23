# Домашнее задание к занятию "`Итоговый проект Облачная инфраструктура`" - `Татаринцев Алексей`


### Задание 1


1. `Поднимать инфраструктуру буду на Terraform.`
2. `Добавляю основные файлы проекта `

```
providers.tf
terraform.tfvars
terraformrc
variables.tf
```
3. `Приступаю к конфигурированию основного файла main.tf`

```
# --- Используем существующую подсеть ---
data "yandex_vpc_subnet" "default" {
  subnet_id = var.subnet_id
}

# --- Security Group ---
resource "yandex_vpc_security_group" "default" {
  name       = "allow-ssh-http-https"
  network_id = data.yandex_vpc_subnet.default.network_id

  ingress {
    protocol = "TCP"
    port     = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "TCP"
    port     = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "TCP"
    port     = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- VM ---
resource "yandex_compute_instance" "vm" {
  name        = "simple-vm"
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id          = data.yandex_vpc_subnet.default.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.default.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.public_key}"
  }
}

# --- Managed MySQL ---
resource "yandex_mdb_mysql_cluster" "mysql" {
  name        = "simple-mysql"
  environment = "PRESTABLE"
  network_id  = data.yandex_vpc_subnet.default.network_id

  version     = "8.0"  

  resources {
    resource_preset_id = "s2.micro"
    disk_size          = 10
    disk_type_id       = "network-ssd"
  }

  host {
    zone      = var.zone
    subnet_id = data.yandex_vpc_subnet.default.id
  }

  database {
    name = "mydb"
  }

  user {
  name     = "alexey"
  password = "Cnews220"

  permission {
    database_name = "mydb"
    roles         = ["ALL"]
   }
  }
}


# --- Container Registry ---
resource "yandex_container_registry" "registry" {
  name = "simple-registry"
}

```



4. `Захожу в YC и проверяю что есть`

![1](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img1.png)`


### Задание 2

1. `Дописываю main.tf`
```
resource "yandex_compute_instance" "vm" {
  name        = "simple-vm"
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id          = data.yandex_vpc_subnet.default.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.default.id]
  }

  metadata = {
    ssh-keys  = "ubuntu:${var.public_key}"
    user-data = <<-EOF
      #cloud-config
      package_update: true
      package_upgrade: true
      packages:
        - docker.io
        - docker-compose
      runcmd:
        - systemctl start docker
        - systemctl enable docker
        - usermod -aG docker ubuntu
    EOF
  }
}

```

2. `Проверяю работу `
```
terraform init
terraform plan
terraform apply

```
3. `Проверяю, что установился Docker и Docker Compose`

![2](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img2.png)`


---

### Задание 3



1. `Создаю Dockerfile с наполнением`
```
# Используем официальный образ NGINX
FROM nginx:latest

# Документируем порт
EXPOSE 80
```

2. `Также создаю каталог html и в нем файл indexс наполнением`

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>My NGINX App</title>
</head>
<body>
  <h1>Hello from my custom NGINX container!</h1>
  <p>This page is served by NGINX inside a Docker container.</p>
</body>
</html>

```
3. `Собираю образ`

```
docker build -t my-nginx:latest .
```
4. `Посмотреть твой Registry ID`

```
yc container registry list
```
5. `Тегирую под Yandex Container Registry`
```
docker tag my-nginx:latest cr.yandex/crpne9j6e0oo9k3t7pfb/my-nginx:latest
```

6. `Логинюсь в Registry`

```
yc container registry configure-docker
```
7. `Заливаю образ`

```
docker push cr.yandex/crpne9j6e0oo9k3t7pfb/my-nginx:latest
```
![3](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img3.png)`

8. `Проверяю`  

```
docker run --rm -p 8080:80 cr.yandex/crpne9j6e0oo9k3t7pfb/my-nginx:latest
```
![4](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img4.png)`

![5](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img5.png)`


### Задание 4



1. `Для задания делаю каталог fastapi-db-appс наполнением из трех вайлов.`
2. `app.py`
```
from fastapi import FastAPI
import mysql.connector
import os

app = FastAPI()

db_host = os.getenv("DB_HOST")
db_user = os.getenv("DB_USER")
db_pass = os.getenv("DB_PASSWORD")
db_name = os.getenv("DB_NAME")

@app.get("/")
def root():
    conn = mysql.connector.connect(
        host=db_host, user=db_user, password=db_pass, database=db_name)
    cur = conn.cursor()
    cur.execute("SELECT NOW()")
    now = cur.fetchone()[0]
    return {"mysql_time": str(now)}

```
3. `Dockerfile`
```
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 80
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "80"]

```
4. `requirements.txt`

```
fastapi
uvicorn
mysql-connector-python

```

5. ` Сборка и пуш в Registry`

```
docker build -t fastapi-db-app:latest .
docker tag fastapi-db-app:latest cr.yandex/crpne9j6e0oo9k3t7pfb/fastapi-db-app:latest
yc container registry configure-docker
docker push cr.yandex/crpne9j6e0oo9k3t7pfb/fastapi-db-app:latest
```
![8](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img8.png)`


6. ` Захожу на ВМ и проверяю`
```
ssh ubuntu@51.250.79.88

yc container registry configure-docker

terraform output mysql_fqdn

docker run -d -p 80:80 \
  -e DB_HOST=rc1a-n5m2e1jdhdkdkmfp.mdb.yandexcloud.net \
  -e DB_USER=alexey \
  -e DB_PASSWORD=Cnews220 \
  -e DB_NAME=mydb \
  cr.yandex/crpne9j6e0oo9k3t7pfb/fastapi-db-app:latest


docker ps

```

![7](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img7.png)`

7. `Первым делом надо было спрятать на .gitignore все секреты.`

```
.terraform/
terraform.tfstate
terraform.tfstate.backup
crash.log
*.tfvars
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraform.lock.hcl
```
