Add-Type -AssemblyName System.Drawing

$dir = "c:\Users\pmumo\Desktop\ART\img"
$files = Get-ChildItem -Path $dir -Filter "*.jpg"

foreach ($file in $files) {
    Write-Host "Processing $($file.Name)..."
    
    # Load image
    $img = [System.Drawing.Image]::FromFile($file.FullName)
    
    # Calculate new dimensions
    $maxWidth = 1200
    if ($img.Width -gt $maxWidth) {
        $ratio = $maxWidth / $img.Width
        $newWidth = $maxWidth
        $newHeight = [Math]::Floor($img.Height * $ratio)
        Write-Host "  Resizing to ${newWidth}x${newHeight}"
    } else {
        $newWidth = $img.Width
        $newHeight = $img.Height
        Write-Host "  No resize needed, applying compression only."
    }
    
    # Create new bitmap
    $newImg = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
    $g = [System.Drawing.Graphics]::FromImage($newImg)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($img, 0, 0, $newWidth, $newHeight)
    
    # Dispose original to release file lock
    $img.Dispose()
    $g.Dispose()
    
    # Setup JPEG compression codec
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]75)
    
    # Overwrite the original file with optimized version
    $newImg.Save($file.FullName, $codec, $encoderParams)
    $newImg.Dispose()
    
    Write-Host "  Done."
}

Write-Host "Optimization complete."
