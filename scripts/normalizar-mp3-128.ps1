$Source = "C:\Ruta\A\Tu\BibliotecaOriginal"
$Destination = "C:\Ruta\A\Tu\BibliotecaNormalizada_128kbps"

$Source = (Resolve-Path $Source).Path.TrimEnd('\')
New-Item -ItemType Directory -Force -Path $Destination | Out-Null

$logPath = Join-Path $Destination "_normalizacion_128kbps_log.txt"

"Inicio: $(Get-Date)" | Out-File $logPath -Encoding UTF8
"Origen: $Source" | Out-File $logPath -Append -Encoding UTF8
"Destino: $Destination" | Out-File $logPath -Append -Encoding UTF8
"" | Out-File $logPath -Append -Encoding UTF8

Get-ChildItem -Path $Source -Filter *.mp3 -File -Recurse | ForEach-Object {
    $inputFile = $_.FullName

    # Conserva la estructura relativa si hay subcarpetas.
    # Si todo está en raíz, simplemente conserva el mismo nombre.
    $relativePath = $inputFile.Substring($Source.Length).TrimStart('\')
    $outputFile = Join-Path $Destination $relativePath
    $outputDir = Split-Path $outputFile -Parent

    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

    if (Test-Path $outputFile) {
        Write-Host "Saltando, ya existe: $outputFile"
        "SKIP`t$inputFile`t$outputFile" | Out-File $logPath -Append -Encoding UTF8
        return
    }

    Write-Host "Normalizando: $inputFile"

    & ffmpeg `
        -hide_banner `
        -y `
        -i "$inputFile" `
        -vn `
        -map 0:a:0 `
        -c:a libmp3lame `
        -b:a 128k `
        -ar 44100 `
        -ac 2 `
        -map_metadata 0 `
        -id3v2_version 3 `
        "$outputFile"

    if ($LASTEXITCODE -eq 0 -and (Test-Path $outputFile)) {
        Write-Host "OK: $outputFile"
        "OK`t$inputFile`t$outputFile" | Out-File $logPath -Append -Encoding UTF8
    } else {
        Write-Host "ERROR: $inputFile"
        "ERROR`t$inputFile`t$outputFile" | Out-File $logPath -Append -Encoding UTF8
    }
}

"" | Out-File $logPath -Append -Encoding UTF8
"Fin: $(Get-Date)" | Out-File $logPath -Append -Encoding UTF8

Write-Host "Normalización terminada."
Write-Host "Log: $logPath"