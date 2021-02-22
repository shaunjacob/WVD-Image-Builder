Input: devs push new release

# WinUI image build
1. Fetch build artifacts (nuget files)
2. Push into file storage
3. Generate SAS URL
4. Modify image template customization script to use generated SAS URL
  - token exposed as var `$(package.StorageContainerSasToken)`
  - Pull secrets from vault? and update MasterAppSettings.config
5. Kick off build

## WVD Host pool
Prereqs: Host pool must exist. Terraform?

1. Generate registration token
2. Enumerate VMs in current host pool
3. Add new VMs to host pool (latest image)
4. Set "Drain" status for VMs found in step 2

## Scheduled WVD cleanup pipeline
1. Enumerate drained VMs in current host pool
2. Remove them
