output "sa_storage_id" {
  value = yandex_iam_service_account.sa_storage.id
}

output "sa_storage_access_key" {
  value     = "Ключ сохранен в ~/.authorized_key_sa_storage.json"
  sensitive = true
}

output "sa_storage_secret_key" {
  value     = "Ключ сохранен в ~/.authorized_key_sa_storage.json"
  sensitive = true
}