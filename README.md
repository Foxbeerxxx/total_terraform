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
<<<<<<< HEAD

```



4. `Захожу в YC и проверяю что есть`

![1](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img1.png)`

=======

```
4. `Заполните здесь этапы выполнения, если требуется ....`
>>>>>>> 658ee3b242c41136f6054bf6bfeed8692a52188d
5. `Заполните здесь этапы выполнения, если требуется ....`
6. 

```
Поле для вставки кода...
....
....
....
....
```


![1](https://github.com/Foxbeerxxx/total_terraform/blob/main/img/img1.png)`


---

### Задание 2

`Приведите ответ в свободной форме........`

1. `Заполните здесь этапы выполнения, если требуется ....`
2. `Заполните здесь этапы выполнения, если требуется ....`
3. `Заполните здесь этапы выполнения, если требуется ....`
4. `Заполните здесь этапы выполнения, если требуется ....`
5. `Заполните здесь этапы выполнения, если требуется ....`
6. 

```
Поле для вставки кода...
....
....
....
....
```

`При необходимости прикрепитe сюда скриншоты
![Название скриншота 2](ссылка на скриншот 2)`


---

### Задание 3

`Приведите ответ в свободной форме........`

1. `Заполните здесь этапы выполнения, если требуется ....`
2. `Заполните здесь этапы выполнения, если требуется ....`
3. `Заполните здесь этапы выполнения, если требуется ....`
4. `Заполните здесь этапы выполнения, если требуется ....`
5. `Заполните здесь этапы выполнения, если требуется ....`
6. 

```
Поле для вставки кода...
....
....
....
....
```

`При необходимости прикрепитe сюда скриншоты
![Название скриншота](ссылка на скриншот)`

### Задание 4

`Приведите ответ в свободной форме........`

1. `Заполните здесь этапы выполнения, если требуется ....`
2. `Заполните здесь этапы выполнения, если требуется ....`
3. `Заполните здесь этапы выполнения, если требуется ....`
4. `Заполните здесь этапы выполнения, если требуется ....`
5. `Заполните здесь этапы выполнения, если требуется ....`
6. 

```
Поле для вставки кода...
....
....
....
....
```

`При необходимости прикрепитe сюда скриншоты
![Название скриншота](ссылка на скриншот)`
