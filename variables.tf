###cloud vars

variable "public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5m9AhMRWiO+yybLYEHaJhFaODFZDTbOiYqitAxzWgs alexey@dell"
}
variable "image_id" {
  description = "ID образа для ВМ"
  type        = string
}

variable "subnet_id" {
  description = "ID подсети"
  type        = string
}

variable "zone" {
  description = "Зона размещения ресурсов"
  type        = string
  default     = "ru-central1-a"
}
