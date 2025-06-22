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
