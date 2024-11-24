# Login to Azure account
Connect-AzAccount

# Define variables
$resourceGroupName = "myResourceGroup"
$location = "East US"
$vmName = "myVM"
$vmSize = "Standard_B1s"
$adminUsername = "azureuser"
$adminPassword = "P@ssw0rd1234"  # Use a secure password
$publicIpName = "myPublicIP"
$networkInterfaceName = "myNIC"
$vnetName = "myVNet"
$subnetName = "mySubnet"

# Create a Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a Virtual Network and Subnet
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location `
                             -Name $vnetName -AddressPrefix "10.0.0.0/16"

$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet `
                                                -AddressPrefix "10.0.0.0/24"

# Create the Public IP
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location `
                                   -Name $publicIpName -AllocationMethod Dynamic

# Create a Network Interface
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location `
                              -Name $networkInterfaceName -SubnetId $subnetConfig.Id `
                              -PublicIpAddressId $publicIp.Id

# Create the VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize

# Configure OS and network settings
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName `
                                     -Credential (New-Object System.Management.Automation.PSCredential($adminUsername, (ConvertTo-SecureString $adminPassword -AsPlainText -Force))) `
                                     -ProvisionVMAgent -EnableAutoUpdate

$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

# Deploy the VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

Write-Host "VM $vmName has been successfully deployed!"
