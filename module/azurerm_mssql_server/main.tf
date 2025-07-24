resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password
  version                      = "12.0"
  minimum_tls_version          = "1.2"
}