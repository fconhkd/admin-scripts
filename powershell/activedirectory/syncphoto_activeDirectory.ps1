[CmdletBinding(SupportsShouldProcess=$true)]Param()
function Test-Null($InputObject) { return !([bool]$InputObject) }
Function ResizeImage() {
param([String]$ImagePath, [Int]$Quality = 90, [Int]$targetSize, [String]$OutputLocation)
Add-Type -AssemblyName “System.Drawing”
$img = [System.Drawing.Image]::FromFile($ImagePath)
$CanvasWidth = $targetSize
$CanvasHeight = $targetSize
#Encoder parameter for image quality
$ImageEncoder = [System.Drawing.Imaging.Encoder]::Quality
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($ImageEncoder, $Quality)
# get codec
$Codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where {$_.MimeType -eq ‘image/jpeg’}
#compute the final ratio to use
$ratioX = $CanvasWidth / $img.Width;
$ratioY = $CanvasHeight / $img.Height;
$ratio = $ratioY
if ($ratioX -le $ratioY) {
$ratio = $ratioX
}
$newWidth = [int] ($img.Width * $ratio)
$newHeight = [int] ($img.Height * $ratio)
$bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
$graph = [System.Drawing.Graphics]::FromImage($bmpResized)
$graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graph.Clear([System.Drawing.Color]::White)
$graph.DrawImage($img, 0, 0, $newWidth, $newHeight)
#save to file
$bmpResized.Save($OutputLocation, $Codec, $($encoderParams))
$bmpResized.Dispose()
$img.Dispose()
}
#get sid and photo for current user
$user = ([ADSISearcher]”(&(objectCategory=User)(SAMAccountName=$env:username))”).FindOne().Properties
$user_photo = $user.thumbnailphoto
$user_sid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
Write-Verbose “Updating account picture for $($user.displayname)…”
#continue if an image was returned
If ((Test-Null $user_photo) -eq $false)
{
Write-Verbose “Success. Photo exists in Active Directory.”
#set up image sizes and base path
$image_sizes = @(32, 40, 48, 96, 192, 200, 240, 448)
$image_mask = “Image{0}.jpg”
$image_base = “C:\ProgramData\AccountPictures”
#set up registry
$reg_base = “HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\{0}”
$reg_key = [string]::format($reg_base, $user_sid)
$reg_value_mask = “Image{0}”
If ((Test-Path -Path $reg_key) -eq $false) { New-Item -Path $reg_key }
#save images, set reg keys
ForEach ($size in $image_sizes)
{
#create hidden directory, if it doesn’t exist
$dir = $image_base + “\” + $user_sid
If ((Test-Path -Path $dir) -eq $false) { $(mkdir $dir).Attributes = “Hidden” }
#save photo to disk, overwrite existing files
$file_name = ([string]::format($image_mask, $size))
$pathtmp = $dir + “\_” + $file_name
$path = $dir + “\” + $file_name
Write-Verbose ” saving: $file_name”
$user_photo | Set-Content -Path $pathtmp -Encoding Byte -Force
ResizeImage $pathtmp $size $size $path
Remove-Item $pathtmp
#save the path in registry, overwrite existing entries
$name = [string]::format($reg_value_mask, $size)
$value = New-ItemProperty -Path $reg_key -Name $name -Value $path -Force
}
Write-Verbose “Done.”
} else { Write-Error “No photo found in Active Directory for $env:username” }