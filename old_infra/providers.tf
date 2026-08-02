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

  backend "s3" {
    endpoint   = "https://storage.yandexcloud.net"
    bucket     = "my-terraform-state-14051981"
    region     = "ru-central-1"
    key        = "prod/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
  }
}

# Основной провайдер для создания инфраструктуры
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  service_account_key_file = file("~/.authorized_key.json")
  zone      = var.default_zone
}

# Дополнительный провайдер для создания бакета (от имени sa_storage)
provider "yandex" {
  alias     = "storage"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  service_account_key_file = file("~/.authorized_key_sa_storage.json")
  zone      = var.default_zone
}

# 1. Сервисный аккаунт для управления бакетом
resource "yandex_iam_service_account" "sa_storage" {
  name = "sa-storage-backend"
}

# 2. Назначение роли storage.editor сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa_storage.id}"
}

# 3. Создание статического ключа доступа для работы с S3
resource "yandex_iam_service_account_static_access_key" "sa_storage_key" {
  service_account_id = yandex_iam_service_account.sa_storage.id
  description        = "Static access key for Terraform backend"
}
