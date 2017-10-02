Import-Module .\prometheus.psm1

$metric = Get-Counter | Select-Object -ExpandProperty 'CounterSamples' | ?{$PSItem.InstanceName -match '[a-zA-Z_:][a-zA-Z0-9_:]*'}
$metric = $metric | ConvertTo-PromExposition
$metric

Invoke-WebRequest -Uri "http://localhost:9091/metrics/job/windowscounter" -Method Post -Body $metric