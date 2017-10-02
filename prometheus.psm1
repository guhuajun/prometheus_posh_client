# requires -version 5.0

<#
 # A powershell script for providing a general way to export metrics to prometheus
 #>

function ConvertTo-PromExposition
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Microsoft.PowerShell.Commands.GetCounter.PerformanceCounterSample]
        $Sample
    )

    begin
    {
        $results = New-Object System.Text.StringBuilder
    }

    process
    {
        try
        {
            # Get counter path
            $path = $Sample.Path
            $path = $path.ToLower()

            # Get host name from path
            $hostname = $path.split('\')[2]
            $path = $path -replace $hostname, ''

            # Get instance name
            $instanceName = $Sample.InstanceName.ToLower()
            $path = $path -replace $instanceName, ''
            
            # Make sure metric name is valid
            $pattern = '[a-zA-Z_:][a-zA-Z0-9_:]*'
            $name = @()
            [regex]::Matches($path, $pattern) | %{$name += $PSItem.Value}
            $name = $name -join '_'

            # Get value
            $value = $Sample.CookedValue

            $metric = $name + '{{instance="{0}"}}' -f $instanceName
            
            $result1 = "#HELP {0}`n" -f $name
            $result2 = "#TYPE {0} gauge`n" -f $metric
            $result3 = "{0}`n" -f $value

            $null = $results.Append($result1)
            $null = $results.Append($result2)
            $null = $results.Append($result3)            
        }
        catch
        {
            $PSCmdlet.WriteError($Error[0])
        }
    }

    end
    {
        return $results.ToString().Trim()
    }
}

Export-ModuleMember -Function "ConvertTo-PromExposition"
