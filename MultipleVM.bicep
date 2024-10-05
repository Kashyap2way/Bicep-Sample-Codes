// Parameters
param vmNames array = ['vm1', 'vm2', 'vm3']
param regions array = ['Central US', 'West Europe', 'Southeast Asia']

// Variables
var vmSize = 'Standard_DS1_v2'

// Loop through each VM to create
resource vms 'Microsoft.Compute/virtualMachines@2021-07-01' = [for (vmName, i) in vmNames: {
  name: vmName
  location: regions[i]
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: 'adminuser'
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/azureUser/.ssh/authorized_keys'
              keyData: '>>RSA SSH KEY (Public)<<'
            }
          ]
        }
      }
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmName}-nic')
        }
      ]
    }
  }
}]

// Loop to create NIC and Public IP for each VM
resource nics 'Microsoft.Network/networkInterfaces@2021-05-01' = [for (vmName, i) in vmNames: {
  name: '${vmName}-nic'
  location: regions[i]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', '${vmName}-vnet', '${vmName}-subnet')
          }
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${vmName}-pip')
          }
        }
      }
    ]
  }
}]

resource publicIps 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for (vmName, i) in vmNames: {
  name: '${vmName}-pip'
  location: regions[i]
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}]

resource vnets 'Microsoft.Network/virtualNetworks@2021-05-01' = [for (vmName, i) in vmNames: {
  name: '${vmName}-vnet'
  location: regions[i]
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: '${vmName}-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}]
