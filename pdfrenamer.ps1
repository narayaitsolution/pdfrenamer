# rename_pdf.ps1
# Script PowerShell untuk me-rename file PDF berdasarkan metadata Title
# Pastikan exiftool.exe dan folder exiftool_files berada di folder yang sama dengan script ini.
# Download exiftool dari sini https://exiftool.org/

[CmdletBinding()]
Param()

Write-Host "`n=== Memulai proses rename PDF berdasarkan Title ===`n"

# 1. Dapatkan path folder tempat script saat ini berada
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# 2. Bangun path lengkap untuk exiftool.exe
$exifToolPath = Join-Path $scriptDir "exiftool.exe"

# 3. Cek apakah exiftool.exe tersedia
if (!(Test-Path $exifToolPath)) {
    Write-Host "ExifTool tidak ditemukan di folder script. Pastikan exiftool.exe ada di:"
    Write-Host $scriptDir
    return
}

# 4. Dapatkan folder kerja saat ini (tempat file PDF)
$currentFolder = Get-Location

# 5. Ambil semua file PDF di folder kerja
$pdfFiles = Get-ChildItem $currentFolder -Filter *.pdf -File

if ($pdfFiles.Count -eq 0) {
    Write-Host "Tidak ada file PDF di folder" $currentFolder
    return
}

foreach ($pdf in $pdfFiles) {

    # 6. Jalankan exiftool untuk membaca Title dari metadata PDF
    $title = & $exifToolPath -b -Title $pdf.FullName

    if (![string]::IsNullOrEmpty($title)) {
        # 7. Ganti karakter terlarang di Windows agar tidak error
        $safeTitle = $title -replace '[:\\/?"*<>|"]','-'

        # 8. Buat nama file PDF baru
        $newName = "$safeTitle.pdf"

        # 9. Cek apakah sudah ada file dengan nama sama
        if (Test-Path (Join-Path $pdf.DirectoryName $newName)) {
            Write-Host "Nama file tujuan ($newName) sudah ada. Lewati proses rename untuk $($pdf.Name)."
        } else {
            # 10. Rename file
            Rename-Item -Path $pdf.FullName -NewName $newName -ErrorAction SilentlyContinue
            Write-Host "Rename: $($pdf.Name) -> $newName"
        }
    }
    else {
        Write-Host "Metadata Title tidak ditemukan untuk $($pdf.Name). Lewati."
    }
}

Write-Host "`nProses rename selesai!`n"
