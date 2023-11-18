locals {
  databases = toset(["MariaDB", "MySQL"])
}

resource "random_password" "passwords" {
  for_each = local.databases
  length   = 24
  special  = false
}

resource "aws_secretsmanager_secret" "creds" {
  for_each    = local.databases
  name        = "${each.key}Credentials"
  description = "Credentials for the ${each.key}"
}

resource "aws_secretsmanager_secret_version" "creds" {
  for_each  = local.databases
  secret_id = aws_secretsmanager_secret.creds[each.key].id
  secret_string = jsonencode({
    username = lower(each.key)
    password = random_password.passwords[each.key].result
  })
}
