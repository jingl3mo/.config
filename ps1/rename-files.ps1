param(
    [string]$target = ".",
    [string]$algorithm = "SHA1",
    [switch]$AtOwnFolder
)

foreach ($file in Get-ChildItem -Path $target -File) {
   $hash = (Get-FileHash -Path $file.FullName -Algorithm $algorithm).Hash
    $targetdir = $target
    If($AtOwnFolder) {
        $targetdir = "$target\$hash"
    }
    If($AtOwnFolder -and !(Test-Path -Path $targetdir )){
        New-Item -ItemType directory -Path $targetdir
   }
   Move-Item -Path $file.FullName -Destination ("$targetdir\$hash" + $file.Extension)
}
