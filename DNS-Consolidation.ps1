# Vars
$ZoneToGroup = 'privatelink.blob.core.windows.net'
# Resource Group where the destination DNS Zone is.
$RGName = 'dnstest'


# Get Zones
$zones = Get-AzPrivateDnsZone

# Filter out records for the zone we want to consolidate
foreach ($zonecfg in $zones){

    #$records = Get-AzPrivateDnsRecordSet -ResourceGroupName $zonecfg -ZoneName privatelink.blob.core.windows.net | ?{$_.RecordType -eq 'A'}
    $records += Get-AzPrivateDnsRecordSet -Zone $zonecfg | ?{$_.ZoneName -eq $ZoneToGroup} | ?{$_.RecordType -eq 'A'}
}

Write-Output "Creating New Private DNS Zone"
$zone = New-AzPrivateDnsZone -name $ZoneToGroup -ResourceGroupName $RGName


Write-Output "Populating new DNS Zone..."
# Populate new zone with records matching the zone name
foreach ($record in $records){

    New-AzPrivateDnsRecordSet -name $record.Name -ZoneName $zone.Name -RecordType $record.RecordType -Ttl $record.Ttl -ResourceGroupName $RGName `
    -PrivateDnsRecord $record.Records
} 

Write-Output "Script Complete"