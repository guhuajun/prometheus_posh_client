Import-Module .\prometheus.psm1 -Force


# Example 1
1..100 | %{
    Write-Output -InputObject (Get-Date)
    $metric = Get-Counter | Select-Object -ExpandProperty 'CounterSamples' | ?{$PSItem.InstanceName -match '[a-zA-Z_:][a-zA-Z0-9_:]*'}
    $metric = $metric | ConvertTo-PromExposition
    Write-Output -InputObject $metric
    $response = Invoke-WebRequest -Uri "http://localhost:9091/metrics/job/pushgateway/" -Method Post -Body $metric
    Start-Sleep -Seconds 2
}
