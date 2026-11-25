# Wix kapanmadan ONCE calistir: resimleri ve logoyu img klasorune indirir.
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = "SilentlyContinue"
$img = $PSScriptRoot
$hata = 0
$resimler = [ordered]@{
  "start" = "a9f1e3_b75df282b6b54596946f0db4dc63f9d8~mv2.jpg"
  "sprachmittlung" = "a9f1e3_e0f01d3b816b4b3e9e78775187b8045c~mv2.jpg"
  "oeffnungszeiten" = "972a873e0f364698ab3b642f7539f05b.jpg"
  "dolmetschen" = "11062b_0f4115861806481da162e5447f867b05~mv2.jpg"
  "beglaubigt" = "a9f1e3_dd0e3cd6cd5549b5a64cd84e296870cd~mv2.jpg"
  "express" = "a9f1e3_7a98d153b1a24bc49f1fa04bea0568cb~mv2.jpg"
  "ueber-uns" = "a9f1e3_6fd44f5147f845da99ef4cc2f75a779c~mv2.jpg"
  "kontakt" = "a9f1e3_21b5754a86404493aad936b7f8a84a97~mv2.jpg"
}
foreach ($ad in $resimler.Keys) {
  $adres = "https://static.wixstatic.com/media/" + $resimler[$ad]
  $hedef = Join-Path $img "$ad.jpg"
  try {
    try { Invoke-WebRequest -UseBasicParsing "$adres/v1/fit/w_1600,h_1600,q_85/foto.jpg" -OutFile $hedef }
    catch { Invoke-WebRequest -UseBasicParsing $adres -OutFile $hedef }
    Write-Host "TAMAM  $ad.jpg"
  } catch { Write-Host "HATA   $ad.jpg  $($_.Exception.Message)"; $hata++ }
}
try {
  $sayfa = (Invoke-WebRequest -UseBasicParsing "https://www.textflows.de/").Content
  $ikonlar = [ordered]@{ "logo" = "9 22.5 182 155.002"; "icon1" = "20.001 22.59 160 154.822"; "icon2" = "38.818 20 122.364 160"; "icon3" = "24.53 20 150.941 160"; "icon4" = "20.605 20 158.864 159.998" }
  foreach ($ad in $ikonlar.Keys) {
    $m = [regex]::Match($sayfa, '(?s)<svg\b[^>]*viewBox="' + [regex]::Escape($ikonlar[$ad]) + '"[^>]*>.*?</svg>')
    if (-not $m.Success) { Write-Host "HATA   $ad.svg bulunamadi"; $hata++; continue }
    $svg = $m.Value -replace 'fill="(?!none)[^"]*"', ''
    $bas = [regex]::Match($svg, '^<svg[^>]*>').Value
    $yeni = $bas -replace '\s(xmlns|fill|style)="[^"]*"', ''
    $yeni = $yeni -replace '^<svg', '<svg xmlns="http://www.w3.org/2000/svg" fill="#e4ea6b"'
    $svg = $yeni + $svg.Substring($bas.Length)
    if ($svg -match 'xlink:' -and $yeni -notmatch 'xmlns:xlink') { $svg = $svg -replace '^<svg', '<svg xmlns:xlink="http://www.w3.org/1999/xlink"' }
    [IO.File]::WriteAllText((Join-Path $img "$ad.svg"), $svg, (New-Object Text.UTF8Encoding $false))
    Write-Host "TAMAM  $ad.svg"
  }
} catch { Write-Host "HATA   logo/ikonlar: $($_.Exception.Message)"; $hata++ }
if ($hata -eq 0) { Write-Host "`nBITTI. Hepsi indi." } else { Write-Host "`n$hata hata var. Bu ekranin fotografini gonder." }
