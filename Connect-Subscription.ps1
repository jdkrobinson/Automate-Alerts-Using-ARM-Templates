<#
    Preamble
#>    

<# Functions #>
function Confirm-Context {
    param (
        $context
    )
    Write-Output "Current context is"
    $context | Select-Object *
    $userResponse = Read-Host -Prompt "Does this look like the environment you wish to make changes in? [y/n]"
    if ($userResponse -ne "y") {
        Connect-MyAccount      
    }
}

function Connect-MyAccount {
    Clear-AzContext #remove all other contexts, to avoid confusion and complication
    $Environment = 'AzureCloud'        
    $profile = Connect-AzAccount -Environment $Environment
    $subscription = Get-AzSubscription |  Out-GridView -PassThru
    Set-AzContext -Tenant $subscription.TenantId -SubscriptionId $subscription.Id -DefaultProfile $profile
    Write-Host "Logged in to Azure." -ForegroundColor Green
    Test-MyAccount -subscription $subscription -profile $profile
}

function Test-MyAccount {
    param (
        $subscription,
        $profile
    )
    $resourceGroups = Get-AzResouceGroup -ErrorAction SilentlyContinue
    if ($null -eq $resourceGroups){
        Write-Warning "There was an issue getting resources. Attempting Azure log in again"
        Clear-AzContext -Force
        $Environment = 'AzureCloud'    
        $profile = Connect-AzAccount -Environment $Environment -TenantId $subscription.TenantId -SubscriptionId $subscription.Id
        Write-Host "Successfully logged in to Azure." -ForegroundColor Green
    }
    Write-Output "======================= Context is now: ======================="
    Get-AzContext
}


<# Start work here #>
$context = Get-AzContext

if ($null -eq $context){
    Connect-MyAccount    
} else {
    Confirm-Context $context   
}