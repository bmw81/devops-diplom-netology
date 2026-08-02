terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  required_version = ">= 0.13"
}

# Основной провайдер для создания инфраструктуры
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  service_account_key_file = var.service_account_key_file
  zone      = var.default_zone
}
