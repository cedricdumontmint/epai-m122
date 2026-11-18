# windows-checks.ps1 - sondes Windows pour le cours m122 (aucun corrigé).
# Usage : ./windows-checks.ps1 -Sortie resultats.txt   (sous pwsh 7 ET powershell 5.1)
param([string]$Sortie = 'resultats.txt')
$ErrorActionPreference = 'Continue'
Set-Content -Path $Sortie -Value "m122 - sondes Windows" -Encoding ascii
function Note([string]$t) { Add-Content -Path $Sortie -Value $t -Encoding ascii; Write-Host $t }
function Sonde([string]$nom, [scriptblock]$code) {
    Note ""
    Note "== $nom"
    try { $r = & $code 2>&1 | Out-String; Note ($r.TrimEnd()) }
    catch { Note "ERREUR : $($_.Exception.GetType().Name) : $($_.Exception.Message)" }
}
$tmp = Join-Path ([IO.Path]::GetTempPath()) 'm122-sondes'
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$moi = if ($PSVersionTable.PSVersion.Major -ge 6) { 'pwsh' } else { 'powershell' }

Sonde 'version' { $PSVersionTable | Format-Table -AutoSize | Out-String; (Get-Command $moi).Source; [Environment]::OSVersion.VersionString; [Environment]::MachineName }
Sonde 'politique d''execution' { Get-ExecutionPolicy -List | Format-Table -AutoSize | Out-String; Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force; Get-ExecutionPolicy -Scope Process }
Sonde 'alias ls, cat, sort, grep' { foreach ($n in 'ls','cat','sort','grep','echo') { $c = Get-Command $n -ErrorAction SilentlyContinue; "$n -> " + $(if ($c) { "$($c.CommandType) $($c.Definition)" } else { 'absent' }) } }

# Encodage : BOM par défaut
Sonde 'encodage par defaut (octets ecrits)' {
    $f1 = Join-Path $tmp 'sc.txt'; $f2 = Join-Path $tmp 'of.txt'; $f3 = Join-Path $tmp 'redir.txt'; $f4 = Join-Path $tmp 'u8.txt'
    Set-Content $f1 'éa'; 'éa' | Out-File $f2; 'éa' > $f3; Set-Content $f4 'éa' -Encoding utf8
    foreach ($f in $f1,$f2,$f3,$f4) { $b = [IO.File]::ReadAllBytes($f); (Split-Path $f -Leaf) + ' : ' + (($b | Select-Object -First 6 | ForEach-Object { '{0:X2}' -f $_ }) -join ' ') }
}
Sonde 'Import-Csv avec BOM et en Windows-1252' {
    $bom = Join-Path $tmp 'bom.csv'; [IO.File]::WriteAllText($bom, "nom;prenom`r`nMuller;Jörg`r`n", (New-Object Text.UTF8Encoding $true))
    (Import-Csv $bom -Delimiter ';' | Format-List | Out-String)
    (Get-Content $bom -TotalCount 1 | ForEach-Object { $_.ToCharArray() | Select-Object -First 3 | ForEach-Object { [int]$_ } }) -join ' '
    $w = Join-Path $tmp 'w1252.csv'; [IO.File]::WriteAllBytes($w, [Text.Encoding]::GetEncoding(1252).GetBytes("nom;prenom`r`nMuller;Jörg`r`n"))
    (Import-Csv $w -Delimiter ';' | Format-List | Out-String)
}

# Codes de sortie
Sonde 'exit 3 : -File contre -Command' {
    $s = Join-Path $tmp 'sortie3.ps1'; Set-Content $s 'exit 3'
    & $moi -NoProfile -File $s; "-File : $LASTEXITCODE"
    & $moi -NoProfile -Command "& '$s'"; "-Command : $LASTEXITCODE"
    & $moi -NoProfile -Command "exit 3"; "-Command exit 3 : $LASTEXITCODE"
}
Sonde 'Read-Host sans console' {
    $s = Join-Path $tmp 'rh.ps1'; Set-Content $s '$n = Read-Host "Nom"; "recu=[$n]"'
    'ligne' | & $moi -NoProfile -NonInteractive -File $s; "code : $LASTEXITCODE"
    cmd /c "$moi -NoProfile -NonInteractive -File `"$s`" < NUL"; "code (stdin nul) : $LASTEXITCODE"
}

# Planificateur de tâches
Sonde 'ScheduledTasks : module et cmdlets' { (Get-Command *ScheduledTask* | Select-Object -ExpandProperty Name) -join ', ' }
Sonde 'ScheduledTasks : enregistrer, lancer, lire, retirer' {
    $script = Join-Path $tmp 'tache.ps1'; $trace = Join-Path $tmp 'tache.txt'
    Set-Content $script "Set-Content -Path '$trace' -Value ('ok ' + `$PSVersionTable.PSVersion + ' dir=' + (Get-Location) + ' PATH=' + `$env:PATH.Length)"
    $exe = (Get-Command $moi).Source
    $a = New-ScheduledTaskAction -Execute $exe -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
    $t = New-ScheduledTaskTrigger -Daily -At 02:00
    Register-ScheduledTask -TaskName 'M122-Sonde' -Action $a -Trigger $t | Out-String
    Get-ScheduledTask -TaskName 'M122-Sonde' | Select-Object TaskName, State | Format-Table -AutoSize | Out-String
    Start-ScheduledTask -TaskName 'M122-Sonde'
    for ($i = 0; $i -lt 30 -and -not (Test-Path $trace); $i++) { Start-Sleep 1 }
    Start-Sleep 2
    'trace : ' + $(if (Test-Path $trace) { Get-Content $trace } else { 'ABSENTE' })
    (Get-ScheduledTaskInfo -TaskName 'M122-Sonde' | Select-Object LastTaskResult, NumberOfMissedRuns | Format-List | Out-String)
    Unregister-ScheduledTask -TaskName 'M122-Sonde' -Confirm:$false
    'retiree : ' + (-not (Get-ScheduledTask -TaskName 'M122-Sonde' -ErrorAction SilentlyContinue))
}
Sonde 'schtasks : creer, lancer, supprimer' {
    schtasks /create /tn M122-Schtasks /tr "cmd /c echo ok > `"$tmp\schtasks.txt`"" /sc daily /st 02:00 /f
    schtasks /run /tn M122-Schtasks
    Start-Sleep 5
    'trace : ' + $(if (Test-Path "$tmp\schtasks.txt") { 'presente' } else { 'ABSENTE' })
    schtasks /delete /tn M122-Schtasks /f
}
Sonde 'declencheurs disponibles' { (Get-Command New-ScheduledTaskTrigger).Parameters.Keys -join ', ' }

# Journal d'événements
Sonde 'journal : cmdlets presentes' { foreach ($n in 'Write-EventLog','New-EventLog','Get-EventLog','Get-WinEvent','New-WinEvent') { "$n : " + [bool](Get-Command $n -ErrorAction SilentlyContinue) } }
Sonde 'journal : eventcreate puis relecture' {
    eventcreate /L APPLICATION /T INFORMATION /SO M122 /ID 100 /D "m122 sonde eventcreate"
    Start-Sleep 2
    Get-WinEvent -FilterHashtable @{ LogName = 'Application'; ProviderName = 'M122' } -MaxEvents 1 | Select-Object Id, ProviderName, Message | Format-List | Out-String
}
Sonde 'journal : Write-EventLog (5.1) / .NET EventLog' {
    if (Get-Command Write-EventLog -ErrorAction SilentlyContinue) {
        New-EventLog -LogName Application -Source 'M122-Sauvegarde' -ErrorAction SilentlyContinue
        Write-EventLog -LogName Application -Source 'M122-Sauvegarde' -EntryType Information -EventId 1000 -Message 'sauvegarde : début'
        'Write-EventLog : ok'
    } else { 'Write-EventLog absent' }
    if (-not [Diagnostics.EventLog]::SourceExists('M122-Net')) { [Diagnostics.EventLog]::CreateEventSource('M122-Net', 'Application') }
    [Diagnostics.EventLog]::WriteEntry('M122-Net', 'sonde .NET', 'Information', 2000)
    '.NET EventLog : ok'
}

# Comptes locaux
Sonde 'comptes : New-LocalUser, net user, groupe, suppression' {
    $mdp = ConvertTo-SecureString 'Sonde-Aleatoire-9x!' -AsPlainText -Force
    New-LocalUser -Name 'm122sonde' -Password $mdp -FullName 'Sonde m122' -PasswordNeverExpires:$false | Out-String
    net user m122sonde /logonpasswordchg:yes
    net user m122sonde | Select-String 'Mot de passe|Password|Nom complet|Full Name' | Out-String
    try { New-LocalUser -Name ('a' * 21) -NoPassword | Out-Null; 'nom de 21 signes : accepte' } catch { 'nom de 21 signes : ' + $_.Exception.Message }
    Remove-LocalUser -Name 'm122sonde'
    'supprime : ' + (-not (Get-LocalUser -Name 'm122sonde' -ErrorAction SilentlyContinue))
}

# Verrou par fichier et délai maximal
Sonde 'verrou par ouverture exclusive' {
    $v = Join-Path $tmp 'verrou.lock'
    $fs = [IO.File]::Open($v, 'OpenOrCreate', 'ReadWrite', 'None')
    try { $fs2 = [IO.File]::Open($v, 'OpenOrCreate', 'ReadWrite', 'None'); 'second verrou : OBTENU (inattendu)' } catch { 'second verrou : ' + $_.Exception.GetType().Name }
    $fs.Dispose()
    $fs3 = [IO.File]::Open($v, 'OpenOrCreate', 'ReadWrite', 'None'); 'apres liberation : obtenu'; $fs3.Dispose()
}
Sonde 'delai maximal : Start-Job / Wait-Job -Timeout' {
    $j = Start-Job { Start-Sleep 20 }; $r = Wait-Job $j -Timeout 2; 'termine dans le delai : ' + [bool]$r + ' ; etat : ' + $j.State; Stop-Job $j; Remove-Job $j -Force
}

# Syntaxe des .ps1 publiés (starter/) sous cette version
Sonde 'syntaxe des .ps1 du depot' {
    $n = 0; $mal = 0
    Get-ChildItem -Recurse -Filter *.ps1 -Path (Split-Path $PSScriptRoot -Parent) -ErrorAction SilentlyContinue | ForEach-Object {
        $t = $null; $e = $null
        [void][Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$t, [ref]$e)
        $n++; if ($e.Count) { $mal++; "$($_.Name) : $($e.Count) erreur(s) : $($e[0].Message)" }
    }
    "$n fichier(s) analyses, $mal avec erreur"
}
Note ""
Note "fin des sondes"
