@description('Subnet ID for the VM')
param subnetId string

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('The size of the VM')
param vmSize string

@description('Username for the Virtual Machine.')
param adminUsername string

//Number of machines to create
var zooKeeperVMCount = 3
var brokerVMCount = 3
var controlCenterVMCount = 1

// Deploy ZooKeeper Machines
module zooModule './virtualMachine.bicep' = [for vm in range(0, zooKeeperVMCount): {
  name: 'zookeeper-0${vm}'
  params: {
    vmName: 'zookeeper-0${vm}'
    adminPasswordOrKey: adminPasswordOrKey
    subnetId: subnetId
    vmSize: vmSize
    adminUsername: adminUsername
  }
}]

//Deploy Broker Machines
module brokerModule './virtualMachine.bicep' = [for i in range(0, brokerVMCount): {
  name: 'broker-0${i}'
  params: {
    vmName: 'broker-0${i}'
    adminPasswordOrKey: '${adminPasswordOrKey}'
    subnetId: subnetId
    vmSize: vmSize
    adminUsername: adminUsername
  }
}]

//Deploy Control Center Machines
module controlCenter './virtualMachine.bicep' = [for i in range(0, controlCenterVMCount): {
  name: 'controlcenter-0${i}'
  params: {
    vmName: 'controlcenter-0${i}'
    adminPasswordOrKey: adminPasswordOrKey
    subnetId: subnetId
    vmSize: vmSize
    adminUsername: adminUsername
  }
}]
