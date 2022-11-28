
##########################################################################################################################################
#                                                                                                                                        #
#                                                                                                                                        #
#	 Author: Aashish                                                                                                                     #
#    Version: v1.0                                                                                                                       #
#    DateModfied: 09/26/2022                                                                                                             #
#    Description: Policy Violation Resources As per Cyber Guidline                                                                       #
#                                                                                                                                        #
#                                                                                                                                        #
#                                                                                                                                        #
#                                                                                                                                        #
##########################################################################################################################################                                                  
                                                                                                                                         
param                                                                                                                                    
(
    [Parameter(Mandatory = $true)][string] $subscriptionId
)

try {


    #$subscriptionId = "bee606aa-74e1-485b-913c-de36c1f86d34"
    Select-AzSubscription -SubscriptionID $subscriptionId

    $subscription = (Get-AzSubscription -SubscriptionId $subscriptionId).Name

    $listVnet = @();
    $listSubnet = @();
    $listSTR = @();
    $listKV = @();
    $listDisk = @();
    $flag = 'false';
    #$subnetCount = @();
    #$storageCount = @();
    #$kvCount = @();
    $htmlbody = ''
    $htmlsubnet = ''
    $htmlstorage = ''
    $htmlkeyvault = ''
    $htmldisk = ''

    #Getting list of resource goups

    #$listRG = (Get-AzResourceGroup).ResourceGroupName

    # Create a DataTable
    $subnetTable = New-Object system.Data.DataTable "subnetTable"
    $subnetCol1 = New-Object system.Data.DataColumn VnetName, ([string])
    $subnetCol2 = New-Object system.Data.DataColumn SubnetName, ([string])
    $subnetCol3 = New-Object system.Data.DataColumn NSGConfigured, ([string])
    $subnetTable.columns.add($subnetCol1)
    $subnetTable.columns.add($subnetCol2)
    $subnetTable.columns.add($subnetCol3)

    # Create a DataTable
    $storageTable = New-Object system.Data.DataTable "storageTable"
    $storageCol1 = New-Object system.Data.DataColumn StorageAccountName, ([string])
    $storageCol2 = New-Object system.Data.DataColumn VirtualNetworkCount, ([string])
    $storageCol3 = New-Object system.Data.DataColumn PublicAccess, ([string])
    $storageCol4 = New-Object system.Data.DataColumn MinimumTlsVersion, ([string])
    $storageTable.columns.add($storageCol1)
    $storageTable.columns.add($storageCol2)
    $storageTable.columns.add($storageCol3)
    $storageTable.columns.add($storageCol4)

    # Create a DataTable
    $kvTable = New-Object system.Data.DataTable "kvTable"
    $kvCol1 = New-Object system.Data.DataColumn VaultName, ([string])
    $kvCol2 = New-Object system.Data.DataColumn VirtualNetworkCount, ([string])
    $kvCol3 = New-Object system.Data.DataColumn PublicAccess, ([string])
    $kvTable.columns.add($kvCol1)
    $kvTable.columns.add($kvCol2)
    $kvTable.columns.add($kvCol3)

    # Create a DataTable
    $diskTable = New-Object system.Data.DataTable "diskTable"
    $diskCol1 = New-Object system.Data.DataColumn VaultName, ([string])
    $diskCol2 = New-Object system.Data.DataColumn VirtualNetworkCount, ([string])
    $diskCol3 = New-Object system.Data.DataColumn Status, ([string])
    $diskTable.columns.add($diskCol1)
    $diskTable.columns.add($diskCol2)
    $diskTable.columns.add($diskCol3)
  
    write-host -----------------------------Vnet---------------------------------
    $listVnet = (Get-AzVirtualNetwork).Name
    if ($listVnet -ne $vnetEmpty) {
        foreach ($vnet in $listVnet) {
            Write-Host $vnet
            $listSubnet = (Get-AzVirtualNetwork -Name $vnet).Subnets
            foreach ($Subnet in $listSubnet) {

                if ($Subnet.NetworkSecurityGroup -eq $empty1) {
                    $subnetRow = $subnetTable.NewRow()
                    $subnetRow.VnetName = $vnet
                    $subnetRow.SubnetName = $Subnet.Name
                    $subnetRow.NSGConfigured = "No"
                    $subnetTable.Rows.Add($subnetRow)
                }

            }
        }
       
            $htmlsubnet = "<table border='1' align='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,helvetica,sans-serif;text-align:left;'><tr style ='font-size:13px;font-weight: normal;background: #FFFFFF'><td style='background-color:#dddddd' align=left><b>Virtual Network Name</b></td><td style='background-color:#dddddd' align=left><b>Subnet Name</b></td><td style='background-color:#dddddd' align=left><b>NSG Configured</b></td></tr>"
            foreach ($subnetRow in $subnetTable.Rows) { 
                $htmlsubnet += "<tr><td>" + $subnetRow[0] + "</td><td>" + $subnetRow[1] + "</td><td>" + $subnetRow[2] + "</td></tr>"
            }
            $htmlsubnet += "</table>" + "<table width='100%' border='0' cellpadding='0' cellspacing='0'> <tr><td><br/> <br /></td></tr></table></td></tr></table></td></tr></table>"
        
    }


    write-host -----------------------------Storage---------------------------------
    #Getting list of Storage Account
   $listSTR = (Get-AzStorageAccount | Where-Object { $_.NetworkRuleSet.DefaultAction -eq 'Allow' -or $_.MinimumTlsVersion -ne 'TLS1_2' }) | Select-Object -Property ResourceGroupName, StorageAccountName

    if ($listSTR -ne $strEmpty) {
        foreach ($storage in $listSTR) {
            Write-Host $storage.StorageAccountName
            $str = Get-AzStorageAccount -ResourceGroupName $storage.ResourceGroupName -Name $storage.StorageAccountName
              Write-Host $str.MinimumTlsVersion
           
                 
                $storageRow = $storageTable.NewRow()
                $storageRow.StorageAccountName = $str.StorageAccountName
                $storageRow.VirtualNetworkCount = $str.NetworkRuleSet.VirtualNetworkRules.Count
                $storageRow.PublicAccess = if($str.NetworkRuleSet.DefaultAction -eq 'Allow'){'YES'} else {'NO'}
                $storageRow.MinimumTlsVersion = if($str.MinimumTlsVersion -eq 'TLS1_2'){'YES'} else {'NO'}
                $storageTable.Rows.Add($storageRow)
            
            #Write-Host $storage.StorageAccountName
            #Write-host $str.NetworkRuleSet.VirtualNetworkRules
            #Write-host $str.NetworkRuleSet.VirtualNetworkRules.Count
            #Write-host $str.NetworkRuleSet.DefaultAction
        }

        $htmlstorage = "<div><br></div><table border='1' align='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,helvetica,sans-serif;text-align:left;'><tr style ='font-size:13px;font-weight: normal;background: #FFFFFF'><td style='background-color:#dddddd' align=left><b>Storage Account Name</b></td><td style='background-color:#dddddd' align=left><b>Virtual Network Count</b></td><td style='background-color:#dddddd' align=left><b>Storage Public Access</b></td><td style='background-color:#dddddd' align=left><b>Minimum Tls Version 1.2</b></td></tr>"
        foreach ($storageRow in $storageTable.Rows) { 
            $htmlstorage += "<tr><td>" + $storageRow[0] + "</td><td>" + $storageRow[1] + "</td><td>" + $storageRow[2] + "</td><td>" + $storageRow[3] + "</td></tr>"
        }
        $htmlstorage += "</table>" + "<table width='100%' border='0' cellpadding='0' cellspacing='0'> <tr><td><br/> <br /></td></tr></table></td></tr></table></td></tr></table>"
    }


    #Getting List of KeyVault
    write-host -----------------------------KeyVault---------------------------------
    $listKV = (Get-AzKeyVault | Select-Object -Property ResourceGroupName, VaultName)
    #$listKV = (Get-AzKeyVault -ResourceGroupName AZRG-EUW-ENA-APP0147_INT-NPD-001)
    if ($listKV -ne $kvEmpty) {
        foreach ($keyvault in $listKV) {
            Write-Host $keyvault.VaultName
            if ($keyvault -ne $keyEmpty) {
                $kv = Get-AzKeyVault -VaultName $keyvault.VaultName -ResourceGroupName $keyvault.ResourceGroupName
                if ($kv.NetworkAcls.DefaultAction -eq 'Allow') {
                    $flag = 'true';
                    $kvRow = $kvTable.NewRow()
                    $kvRow.VaultName = $kv.VaultName
                    $kvRow.VirtualNetworkCount = $kv.NetworkAcls.VirtualNetworkResourceIds.Count
                    $kvRow.PublicAccess = "YES"
                    $kvTable.Rows.Add($kvRow)
                }
            }
            #$kv = Get-AzKeyVault -VaultName $kevvault.VaultName -ResourceGroupName AZRG-EUW-ENA-APP0147_INT-NPD-001
            #Write-Host $kv.NetworkAcls.VirtualNetworkResourceIds.Count
            #Write-Host $kv.NetworkAcls.DefaultAction
            #Write-Host $kv.NetworkAcls.VirtualNetworkResourceIds
            #write-host $kv.NetworkAcls.VirtualNetworkResourceIds
      
        }
         if ($flag -eq 'true') {
        $htmlkeyvault = "<div><br></div><table border='1' align='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,helvetica,sans-serif;text-align:left;'><tr style ='font-size:13px;font-weight: normal;background: #FFFFFF'><td style='background-color:#dddddd' align=left><b>KeyVault Name</b></td><td style='background-color:#dddddd' align=left><b>Virtual Network Count</b></td><td style='background-color:#dddddd' align=left><b>KeyVault Public Access</b></td></tr>"
        foreach ($kvRow in $kvTable.Rows) { 
            $htmlkeyvault += "<tr><td>" + $kvRow[0] + "</td><td>" + $kvRow[1] + "</td><td>" + $kvRow[2] + "</td></tr>"
        }
        $htmlkeyvault += "</table>" + "<table width='100%' border='0' cellpadding='0' cellspacing='0'> <tr><td><br/> <br /></td></tr></table></td></tr></table></td></tr></table>"
        }
    }
        


    #Getting List of KeyVault
    write-host -----------------------------disk---------------------------------

    $listDisk = (Get-AzDisk | Where-Object { $_.ManagedBy -eq $Null }) | Select-Object -Property ResourceGroupName, Name
    if ($listDisk -ne $diskEmpty) {
     
        foreach ($disk in $listDisk) {
            Write-Host $disk.Name
            $diskRow = $diskTable.NewRow()
            $diskRow.VaultName = $disk.Name
            $diskRow.VirtualNetworkCount = $disk.ResourceGroupName
            $diskRow.Status = 'Unattached'
            $diskTable.Rows.Add($diskRow)
      
        }

      
        $htmldisk = "<div><br></div><table border='1' align='Left' cellpadding='2' cellspacing='0' style='color:black;font-family:arial,helvetica,sans-serif;text-align:left;'><tr style ='font-size:13px;font-weight: normal;background: #FFFFFF'><td style='background-color:#dddddd' align=left><b>Disk Name</b></td><td style='background-color:#dddddd' align=left><b>Resource Group Name</b></td><td style='background-color:#dddddd' align=left><b>Disk Status</b></td></tr>"
        foreach ($diskRow in $diskTable.Rows) { 
            $htmldisk += "<tr><td>" + $diskRow[0] + "</td><td>" + $diskRow[1] + "</td><td>" + $diskRow[2] + "</td></tr>"
        }
        $htmldisk += "</table>" + "<table width='100%' border='0' cellpadding='0' cellspacing='0'> <tr><td><br/> <br /></td></tr></table></td></tr></table></td></tr></table>"
    }


    $htmlbody += "<div>Hi Team,<br><br><b>List Of Policy Violation Resources:</b><br><br></div>" + $htmlsubnet + $htmlstorage + $htmlkeyvault + $htmldisk + "<table width='100%' border='0' cellpadding='0' cellspacing='0'> <tr><td><br/> <br />Regards,<br/>GTSReliabilityEngineeringQR</td></tr></table></td></tr></table></td></tr></table>"

    if ($htmlsubnet -ne '' -or $htmlstorage -ne '' -or $htmlkeyvault -ne '' -or $htmldisk -ne '') {
    
        $From = "ops_automation@deloitte.com"
        $To = @('REQRWorkingGroup@deloitte.com')
        #$To = @('aasgarg@deloitte.com')
        $SMTPServer = "appmail.atrame.deloitte.com"
        $SMTPPort = "25"
        $subject = $subscription + " | Policy Violation Resources"
        #$body = "Hi there,<br />Here is a table:<br /><br />" + $html
        Send-MailMessage -From $From -to $To -Subject $Subject -Body $htmlbody -bodyashtml -SmtpServer $SMTPServer -Priority High -port $SMTPPort -UseSsl -DeliveryNotificationOption OnSuccess
    }

}
catch {
    Write-Error "Error Message: $($_.Exception.Message)"
}


