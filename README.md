# Automate-Alerts-Using-ARM-Templates

Here is the description on how and why to use this script.

Have you ever had the tedious task of creating multiple alerts for all of the resources in your subscription? Let me tell you is really time consuming to create them from scratch one by one.

I have a PowerShell Script that can Target and Create specific metric alerts for the resources you define inside of the script. First make sure you have imported the following modules into PowerShell:

-	Az
-	Az.Monitor

Next, lets create two JSON files, one will be parameters.json and the other template.json, lets put them in a local folder.

Now this portion of the code targets only Virtual Machines, but if you want to target additional resource types. Follow this link to view all the supported metrics for Azure Monitor, choose the resource type and metric and give all the desired changes inside of the script.

Change this line: 
$PublicIPs = Get-AzResource -ResourceType "YOUR DESIRED RESOURCE" | Select-Object -Property ResourceId,Name

Supported Metrics and Resources:
https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-metric-near-real-time

Now let’s see the progress in real time!

After the script finishes go to the Deployments section of the resource group you defined, you will see each individual job being deployed.

To run this script you will first need to use the parameters and template JSON files to deploy using the PS Script mentioned.
