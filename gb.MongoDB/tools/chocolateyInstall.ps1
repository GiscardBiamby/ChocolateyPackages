#NOTE: Please remove any commented lines to tidy up prior to releasing the package, including this one

$packageName = 'gbMongoDB' # arbitrary name for the package, used in messages
$mongoVersion = '2.2.3'

$isWin7_2008R2_OrGreater = [Environment]::OSVersion.Version -ge (new-object 'Version' 6,1)
$processor = Get-WmiObject Win32_Processor
$is64bit = $processor.AddressWidth -eq 64

$fileName = "mongodb-win32-i386-2.2.3.zip"
if ($is64bit) {
    if ($isWin7_2008R2_OrGreater) {
        $fileName = "mongodb-win32-x86`_64-$mongoVersion.zip"
    } else {
        $fileName = "mongodb-win32-x86`_64-2008plus-$mongoVersion.zip"
    }
}

$url = "http://downloads.mongodb.org/win32/$fileName"

if ($isWin7_2008R2_OrGreater) {
	$url64 = "http://downloads.mongodb.org/win32/mongodb-win32-x86`_64-2008plus-$mongoVersion.zip"
} 

$binRoot = "$env:systemdrive\"
### Using an environment variable to to define the bin root until we implement YAML configuration ###
if($env:chocolatey_bin_root -ne $null) {
	$binRoot = join-path $env:systemdrive $env:chocolatey_bin_root
}



write-host "url: '$url'"
write-host "url64: '$url64'"

# main helpers - these have error handling tucked into them already
# download and unpack a zip file
Install-ChocolateyZipPackage "$packageName" "$url" "$(Split-Path -parent $MyInvocation.MyCommand.Definition)" 

try { #error handling is only necessary if you need to do anything in addition to/instead of the main helpers
  # other helpers - using any of these means you want to uncomment the error handling up top and at bottom.
  # downloader that the main helpers use to download items
  #Get-ChocolateyWebFile "$packageName" 'DOWNLOAD_TO_FILE_FULL_PATH' "$url" "$url64"
  # installer, will assert administrative rights - used by Install-ChocolateyPackage
  #Install-ChocolateyInstallPackage "$packageName" "$installerType" "$silentArgs" '_FULLFILEPATH_' -validExitCodes $validExitCodes
  # unzips a file to the specified location - auto overwrites existing content
  #Get-ChocolateyUnzip "FULL_LOCATION_TO_ZIP.zip" "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
  # Runs processes asserting UAC, will assert administrative rights - used by Install-ChocolateyInstallPackage
  #Start-ChocolateyProcessAsAdmin 'STATEMENTS_TO_RUN' 'Optional_Application_If_Not_PowerShell' -validExitCodes $validExitCodes
  # add specific folders to the path - any executables found in the chocolatey package folder will already be on the path. This is used in addition to that or for cases when a native installer doesn't add things to the path.
  #Install-ChocolateyPath 'LOCATION_TO_ADD_TO_PATH' 'User_OR_Machine' # Machine will assert administrative rights
  # add specific files as shortcuts to the desktop
  #$target = Join-Path $MyInvocation.MyCommand.Definition "$($packageName).exe"
  #Install-ChocolateyDesktopLink $target
  
  #------- ADDITIONAL SETUP -------#
  # make sure to uncomment the error handling if you have additional setup to do
    
    $zipFileName = [io.path]::GetFileNameWithoutExtension($fileName)
    $scriptPath = $(Join-Path (Split-Path -parent $MyInvocation.MyCommand.Definition) "$zipFileName")
    Write-Host "Script Path: $scriptPath" 

    
    $mongoDir = $scriptPath
    $mongod = join-path $mongoDir 'bin\mongod.exe'

    $dataDir = $(join-path $mongoDir 'data')
    if(!$(test-path $dataDir)){mkdir $dataDir}
    
    $dataDbDir = $(join-path $dataDir 'db')
    if (!$(test-path $dataDbDir)){mkdir $dataDbDir}

    $logsDir = $(join-path $mongoDir 'logs')
    if(!$(test-path $logsDir)){mkdir $logsDir}

    $binDir = join-path $env:chocolateyinstall 'bin'
    $batchFileName = Join-Path $binDir 'MongoRotateLogs.bat'
    "@echo off
    $executable --eval `'db.runCommand(`"logRotate`")`' mongohost:27017/admin" | Out-File $batchFileName -encoding ASCII

    # Install and start mongodb as a Windows service
    Start-ChocolateyProcessAsAdmin "& $mongod --quiet --bind_ip 127.0.0.1 --logpath $(join-path $logsDir 'MongoDB.log') --logappend --dbpath $dataDir --directoryperdb --reinstall; net start `"MongoDB`""


  #$processor = Get-WmiObject Win32_Processor
  #$is64bit = $processor.AddressWidth -eq 64

  
  # the following is all part of error handling
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw 
}