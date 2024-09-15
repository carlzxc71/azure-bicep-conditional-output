// Params
param deploy_vm bool
param environment string

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-${environment}-sc-demo'
  location: resourceGroup().location
  properties: {
     addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
     }
     subnets: [
      {
        name: 'subnet1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
     ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: 'nic-${environment}-sc-demo'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-${environment}-sc-demo'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = if (deploy_vm) {
  name: 'vm-${environment}-sc-demo'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'vm-${environment}-sc-demo'
      adminUsername: 'adminuser'
      adminPassword: 'Password1234!'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource automation_account 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: 'automation-${environment}-sc-demo'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

// If deploy_vm is true, output the VM ID, otherwise output an empty string
output vm_resource_id_prod string = deploy_vm ? vm.id : ''
output automation_account_resource_id string = automation_account.id
