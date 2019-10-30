#Import modules
# Import-Module Az 
Import-Module Az.Monitor

#Reference related scripts
$connectScript = $PSScriptRoot + "\Connect-Subscription.ps1"
& $connectScript

#Resource Group
$resourceGroup = Get-AzResourceGroup |  Out-GridView -PassThru #Select the resource group where the alerts will be created
$resourceGroupName = $resourceGroup.ResourceGroupName

#File Paths. I used this path you can choose any other.
$templateFilePath = $PSScriptRoot + "\template.json"
$parametersFilePath = $PSScriptRoot + "\parameters.json"

################## PUBLIC IP RESOURCES ###########################################################################
#Get Resources
$PublicIPs = Get-AzResource -ResourceType "Microsoft.Network/publicIPAddresses" | `
    Where-Object {$_.Location -eq $resourceGroup.location} | ` #Only get objects in the same location as the resource group where the alerts will be created
    Select-Object -Property ResourceId,Name,Location
######################################################################################################################### 

Write-Host "Creating Metric Alerts for Public IPs"

################## DDoS FOR PUBLIC IPs ##############################
$metricName = "IfUnderDDoSAttack"
$threshold = "0"
$actionGroup = Get-AzActionGroup | Out-GridView -PassThru #User selects Action group
$actionGroupId = $actionGroup.Id
$timeAggregation = "Maximum" # Average, Minimum, Maximum, Total
$alertDescription = "Whether Public IP is under DDoS attack or not. 0 represents normal state. 1 represents attack state"
$operator = "GreaterThan" # Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual
$alertSeverity = 1 # 0,1,2,3,4
$windowSize = "PT1M"
$evaluationFrequency = "PT1M"

foreach ($IP in $PublicIPs){

    #Parameters
    $strIP = $IP.ResourceId
    $strIPName = $IP.Name

    $alertName = "Public IP " + $strIPName + " under DDoS attack"
    Write-Output "Creating..."
    Write-Output $alertName

    #Get JSON
    $paramFile = Get-Content $parametersFilePath -Raw | ConvertFrom-Json

    #Update Values
    $paramFile.parameters.alertName.value = $alertName
    $paramFile.parameters.metricName.value = $metricName
    $paramFile.parameters.resourceId.value = $strIP
    $paramFile.parameters.threshold.value = $threshold
    $paramFile.parameters.actionGroupId.value = $actionGroupId
    $paramFile.parameters.timeAggregation.value = $timeAggregation
    $paramFile.parameters.alertDescription.value = $alertDescription
    $paramFile.parameters.operator.value = $operator
    $paramFile.parameters.alertSeverity.value = $alertSeverity
    $paramFile.parameters.windowSize.value = $windowSize
    $paramFile.parameters.evaluationFrequency.value = $evaluationFrequency

    #Update JSON
    $UpdatedJSON = $paramFile | ConvertTo-Json
    $UpdatedJSON > $parametersFilePath

    #Deploy Template
    $DeploymentName = "PublicIPDDoSAlerts-$strIPName"
    $AlertDeployment = New-AzResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -AsJob

} #EndForEach
