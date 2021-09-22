
# Create a resource group 
resource "azurerm_resource_group" "azure_sql-rg" {
  name     = "${var.env}-${var.project_code_name}-rg"
  location = var.location
}

resource "azurerm_sql_server" "sql_server" {
  name                         = "${var.env}-${var.sql_server_name}-sql-svr"
  resource_group_name          = azurerm_resource_group.azure_sql-rg.name
  location                     = azurerm_resource_group.azure_sql-rg.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.storage_account_name}sa"
  resource_group_name      = azurerm_resource_group.azure_sql-rg.name
  location                 = azurerm_resource_group.azure_sql-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "sql_database" {
  name                = "${var.env}-${var.sql_database_name}-sql-db"
  resource_group_name = azurerm_resource_group.azure_sql-rg.name
  location            = azurerm_resource_group.azure_sql-rg.location
  server_name         = azurerm_sql_server.sql_server.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.storage_account.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.storage_account.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }

  tags = {
    environment = var.environment
  }
}