targetScope = 'subscription'

//////////////////////////
//   Input Parameters   //
//////////////////////////
@description('Optional. A parameter to control which deployments should be executed')
@allowed([
  'All'
  'Only base'
  'Only assets & image'
  'Only image'
])
param deploymentsToPerform string = 'All'

@description('Optional. Specifies the location for resources.')
param location string = 'WestEurope'

/////////////////////////////
//   Template Deployment   //
/////////////////////////////

module imageDeployment '../templates/image.deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-image-sbx'
  params: {
    location: location
    deploymentsToPerform: deploymentsToPerform
    computeGalleryName: 'galaib'
    computeGalleryImageDefinitionName: 'sid-linux'
    computeGalleryImageDefinitions: [
      {
        hyperVGeneration: 'V2'
        name: 'sid-linux'
        osType: 'Linux'
        publisher: 'devops'
        offer: 'devops_linux'
        sku: 'devops_linux_az'
      }
    ]

    assetsStorageAccountName: 'stshaib'
    assetsStorageAccountContainerName: 'aibscripts'

    storageAccountFilesToUpload: [
      {
        name: 'Install-LinuxPowerShell.sh'
        value: loadTextContent('../scripts/uploads/linux/Install-LinuxPowerShell.sh')
      }
      {
        name: 'Initialize-LinuxSoftware.ps1'
        value: loadTextContent('../scripts/uploads/linux/Initialize-LinuxSoftware.ps1')
      }
      // {
      //   name: 'Install-WindowsPowerShell.ps1'
      //   value: loadTextContent('../scripts/uploads/windows/Install-WindowsPowerShell.ps1')
      // }
      // {
      //   name: 'Initialize-WindowsSoftware.ps1'
      //   value: loadTextContent('../scripts/uploads/windows/Initialize-WindowsSoftware.ps1')
      // }
    ]
    // Linux Example
    imageTemplateImageSource: {
      type: 'PlatformImage'
      publisher: 'canonical'
      offer: '0001-com-ubuntu-server-jammy'
      sku: '22_04-lts-gen2'
      version: 'latest'
      // Custom image example
      // type: 'SharedImageVersion'
      // imageVersionID: '${subscription().id}/resourceGroups/myRg/providers/Microsoft.Compute/galleries/galaib/images/sid-linux/versions/0.24470.675'
    }
    imageTemplateCustomizationSteps: [
      {
        type: 'Shell'
        name: 'PowerShell installation'
        scriptUri: 'https://stshaib.blob.${az.environment().suffixes.storage}/aibscripts/Install-LinuxPowerShell.sh'
      }
      {
        type: 'File'
        name: 'Initialize-LinuxSoftware'
        sourceUri: 'https://stshaib.blob.${az.environment().suffixes.storage}/aibscripts/Initialize-LinuxSoftware.ps1'
        destination: 'Initialize-LinuxSoftware.ps1'
      }
      {
        type: 'Shell'
        name: 'Software installation'
        inline: [
          'pwsh \'Initialize-LinuxSoftware.ps1\''
        ]
      }
    ]

    // Windows Example
    // computeGalleryImageDefinitions: [
    //     {
    //         name: 'sid-windows'
    //         osType: 'Windows'
    //         publisher: 'devops'
    //         offer: 'devops_windows'
    //         sku: 'devops_windows_az'
    //     }
    // ]
    // imageTemplateComputeGalleryImageDefinitionName: 'sid-windows'
    // imageTemplateImageSource: {
    //     type: 'PlatformImage'
    //     publisher: 'MicrosoftWindowsDesktop'
    //     offer: 'Windows-10'
    //     sku: '19h2-evd'
    //     version: 'latest'
    // }
    // imageTemplateCustomizationSteps: [
    //     {
    //         type: 'PowerShell'
    //         name: 'PowerShell installation'
    //         inline: [
    //             'Write-Output "Download"'
    //             'wget \'https://stshaib.blob.${environment().suffixes.storage}/aibscripts/Install-WindowsPowerShell.ps1?\' -O \'Install-WindowsPowerShell.ps1\''
    //             'Write-Output "Invocation"'
    //             '. \'Install-WindowsPowerShell.ps1\''
    //         ]
    //         runElevated: true
    //     }
    //     {
    //         type: 'File'
    //         name: 'Initialize-WindowsSoftware'
    //         sourceUri: 'https://stshaib.blob.${az.environment().suffixes.storage}/aibscripts/Initialize-WindowsSoftware.ps1'
    //         destination: 'Initialize-WindowsSoftware.ps1'
    //     }
    //     {
    //         type: 'PowerShell'
    //         name: 'Software installation'
    //         inline: [
    //             'wget \'https://stshaib.blob.${environment().suffixes.storage}/aibscripts/Initialize-WindowsSoftware.ps1?\' -O \'Initialize-WindowsSoftware.ps1\''
    //             'pwsh \'Initialize-WindowsSoftware.ps1\''
    //         ]
    //         runElevated: true
    //     }
    // ]
  }
}
