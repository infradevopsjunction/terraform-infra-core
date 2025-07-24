module "rg" {
  source                  = "../module/azurerm_resource_group"
  resource_group_name     = "harsh-devops-rg"
  resource_group_location = "centralindia"
}
module "vnet" {
  depends_on          = [module.rg]
  source              = "../module/azurerm_virtual_network"
  vnet_name           = "harsh-devops-vnet"
  vnet_location       = "centralindia"
  resource_group_name = "harsh-devops-rg"
  vnet_address_space  = ["10.0.0.0/16"]

}
module "backsubnet" {
  depends_on           = [module.vnet]
  source               = "../module/azurerm_subnet"
  subnet_name          = "harsh-devops-backend-subnet"
  resource_group_name  = "harsh-devops-rg"
  virtual_network_name = "harsh-devops-vnet"
  address_prefixes     = ["10.0.1.0/24"]


}
module "frontsubnet" {
  depends_on           = [module.vnet]
  source               = "../module/azurerm_subnet"
  subnet_name          = "harsh-devops-frontend-subnet"
  resource_group_name  = "harsh-devops-rg"
  virtual_network_name = "harsh-devops-vnet"
  address_prefixes     = ["10.0.2.0/24"]


}
module "public_ip_frontend" {
  depends_on              = [module.rg]
  source                  = "../module/azurerm_public_ip"
  public_ip_name          = "public-ip-frontend"
  resource_group_name     = "harsh-devops-rg"
  resource_group_location = "centralindia"

}
module "public_ip_backend" {
  depends_on              = [module.rg]
  source                  = "../module/azurerm_public_ip"
  public_ip_name          = "public-ip-backend"
  resource_group_name     = "harsh-devops-rg"
  resource_group_location = "centralindia"
}
module "frontend_vm" {
  depends_on           = [module.frontsubnet]
  source               = "../module/azurerm_virtual_machine"
  nic_name             = "frontend-nic"
  location             = "centralindia"
  resource_group_name  = "harsh-devops-rg"
  vm_name              = "frontend-vm"
  admin_username       = "adminuser"
  admin_password       = "P@ssw0rd1234!"
  os_image_publisher   = "Canonical"
  os_image_offer       = "0001-com-ubuntu-server-jammy"
  os_image_sku         = "22_04-lts"
  os_image_version     = "latest"
  subnet_name          = "harsh-devops-frontend-subnet"
  virtual_network_name = "harsh-devops-vnet"
  public_ip_name       = "public-ip-frontend"

}
module "backend_vm" {
  depends_on           = [module.backsubnet]
  source               = "../module/azurerm_virtual_machine"
  nic_name             = "backend-nic"
  location             = "centralindia"
  resource_group_name  = "harsh-devops-rg"
  vm_name              = "backend-vm"
  admin_username       = "adminuser"
  admin_password       = "P@ssw0rd1234!"
  os_image_publisher   = "Canonical"
  os_image_offer       = "0001-com-ubuntu-server-jammy"
  os_image_sku         = "22_04-lts"
  os_image_version     = "latest"
  subnet_name          = "harsh-devops-backend-subnet"
  virtual_network_name = "harsh-devops-vnet"
  public_ip_name       = "public-ip-backend"
}
module "nsg_backend" {
  depends_on           = [module.backsubnet]
  source               = "../module/azurerm_network_security_group"
  nsg_name             = "backend-nsg"
  location             = "centralindia"
  resource_group_name  = "harsh-devops-rg"
  subnet_id            = module.backsubnet.subnet_id
}

module "nsg_frontend" {
  depends_on           = [module.frontsubnet]
  source               = "../module/azurerm_network_security_group"
  nsg_name             = "frontend-nsg"
  location             = "centralindia"
  resource_group_name  = "harsh-devops-rg"
  subnet_id            = module.frontsubnet.subnet_id
}
module "keyvault" {
  source               = "../module/azurerm_key_vault"
  key_vault_name       = "harsh-keyvault"
  location             = "centralindia"
  resource_group_name  = "harsh-devops-rg"
  tenant_id            = "cc6c40f9-d601-4e2c-a589-d18bbc281346"  
  object_id            = "5b27946b-5d9d-45c8-96d6-d761b44210da"      
  secret_name          = "my-secret-password"
  secret_value         = "P@ssw0rd1234!"
}
module "sql_server" {
  source              = "../module/azurerm_mssql_server"
  sql_server_name     = "harsh-mssql-server"
  location            = "centralindia"
  resource_group_name = "harsh-devops-rg"
  admin_login         = "sqladmin"
  admin_password      = "P@ssw0rd1234!"
}

module "sql_database" {
  source              = "../module/azurerm_mssql_database"
  depends_on          = [module.sql_server]
  sql_db_name         = "harshappdb"
  server_id           = module.sql_server.sql_server_id
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  sku_name            = "Basic"
  max_size_gb         = 2
}