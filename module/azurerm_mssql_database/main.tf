resource "azurerm_mssql_database" "sql_db" {
  name           = var.sql_db_name
  server_id      = var.server_id
  collation      = var.collation
  sku_name       = var.sku_name
  max_size_gb    = var.max_size_gb
}