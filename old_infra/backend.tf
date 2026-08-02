resource "yandex_storage_bucket" "tf_state" {
  provider   = yandex.storage       # Использование отдельного провайдера
  bucket     = "my-terraform-state-14051981"
  folder_id  = var.folder_id

  # Включить версионирование для возможности отката состояния
  versioning {
    enabled = true
  }
}