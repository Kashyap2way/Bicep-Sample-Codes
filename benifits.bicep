param location string = resourceGroup().location
param namePrefix string = 'storage1'

var StorageName = '${namePrefix}${uniqueString(resourceGroup().id)}'

var StorageSku = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: StorageName
  location: location
  sku: {
    name: StorageSku
  }
  kind: 'StorageV2'
  properties:{
    accessTier:'Hot'
    supportsHttpsTrafficOnly:true
  }
}

output storageAccountId string = storageAccount.id
