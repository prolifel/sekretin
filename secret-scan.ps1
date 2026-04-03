# secret-scan.ps1 - Scan git history for secrets using regex patterns
# PowerShell version for Windows users
#
# Usage: .\secret-scan.ps1 [--all] [--exit-code N] [--verbose] [--staged]

param(
    [switch]$all,
    [int]$exitCode = 0,
    [switch]$verbose,
    [switch]$staged
)

# Colors for output
$Red = [ConsoleColor]::Red
$Yellow = [ConsoleColor]::Yellow
$Green = [ConsoleColor]::Green

function Write-Color($text, $color) {
    $fg = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $color
    Write-Host $text
    $Host.UI.RawUI.ForegroundColor = $fg
}

# Secret patterns (id:regex)
$Patterns = @{
    0 = @{ Id = "aws-access-key"; Pattern = '(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}' }
    1 = @{ Id = "aws-secret-key"; Pattern = 'aws(.{0,20})[0-9a-zA-Z/+]{40}' }
    2 = @{ Id = "github-token"; Pattern = 'ghp_[0-9a-zA-Z]{36}' }
    3 = @{ Id = "github-oauth"; Pattern = 'gho_[0-9a-zA-Z]{36}' }
    4 = @{ Id = "github-app-token"; Pattern = '(ghu|ghs)_[0-9a-zA-Z]{36}' }
    5 = @{ Id = "github-refresh-token"; Pattern = 'ghr_[0-9a-zA-Z]{36}' }
    6 = @{ Id = "gitlab-token"; Pattern = 'glpat-[0-9a-zA-Z-]{20}' }
    7 = @{ Id = "generic-api-key"; Pattern = '(api[_-]?key|apikey|api[_-]?secret)[^a-zA-Z0-9].{0,20}[0-9a-zA-Z]{16,}' }
    8 = @{ Id = "private-key"; Pattern = '-----BEGIN [A-Z ]*PRIVATE KEY-----' }
    9 = @{ Id = "jwt"; Pattern = 'eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*' }
    10 = @{ Id = "gcp-api-key"; Pattern = 'AIza[0-9A-Za-z_-]{35}' }
    11 = @{ Id = "gcp-service-account"; Pattern = '"type"\s*:\s*"service_account"' }
    12 = @{ Id = "gcp-oauth-token"; Pattern = 'ya29\.[0-9A-Za-z_-]+' }
    13 = @{ Id = "alibaba-access-key-id"; Pattern = 'LTAI[a-zA-Z0-9]{17}' }
    14 = @{ Id = "alibaba-secret-key"; Pattern = 'alibaba(.{0,20})[0-9a-zA-Z]{30}' }
    15 = @{ Id = "amazon-oauth-client-id"; Pattern = 'amzn1\.application-oa2\.[0-9a-zA-Z]{3,}' }
    16 = @{ Id = "anthropic-api-key"; Pattern = 'sk-ant-[a-zA-Z0-9_-]{95}' }
    17 = @{ Id = "artifactory-api-key"; Pattern = 'AKCp8[0-9a-zA-Z]{78}' }
    18 = @{ Id = "artifactory-identity-token"; Pattern = 'AKCp6[0-9a-zA-Z]{78}' }
    19 = @{ Id = "atlassian-api-key"; Pattern = 'ATATT3[A-Za-z0-9_-]{200,}' }
    20 = @{ Id = "atlassian-api-token"; Pattern = 'ATAT[0-9a-zA-Z]{200,}' }
    21 = @{ Id = "atlassian-user-api-token"; Pattern = '[a-zA-Z0-9]{24}:[a-zA-Z0-9]{24}' }
    22 = @{ Id = "aws-bedrock-key"; Pattern = 'aws/bedrock[0-9a-zA-Z]{40}' }
    23 = @{ Id = "aws-bedrock-short-lived-key"; Pattern = 'bedrock-runtime[0-9a-zA-Z/-]{20,}' }
    24 = @{ Id = "azure-api-management-gateway-key"; Pattern = 'AzureML[a-zA-Z0-9]{32}' }
    25 = @{ Id = "azure-api-management-direct-key"; Pattern = 'amlsig[0-9a-zA-Z]{64}' }
    26 = @{ Id = "azure-entra-client-secret"; Pattern = '[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}' }
    27 = @{ Id = "azure-entra-client-id-token"; Pattern = 'azure-ml[0-9a-z]{8}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{12}' }
    28 = @{ Id = "azure-functions-api-key"; Pattern = '[a-zA-Z0-9]{32}-[a-zA-Z0-9]{8}' }
    29 = @{ Id = "azure-openai-api-key"; Pattern = 'azureopenai[0-9a-zA-Z]{32,}' }
    30 = @{ Id = "azure-personal-access-token"; Pattern = 'pat\.[a-zA-Z0-9]{32,}' }
    31 = @{ Id = "bitbucket-client-id"; Pattern = 'bitbucket[0-9a-zA-Z]{20,}' }
    32 = @{ Id = "bitbucket-client-secret"; Pattern = 'bitbucket_secret[0-9a-zA-Z]{32,}' }
    33 = @{ Id = "datadog-api-key"; Pattern = '[0-9a-f]{32}' }
    34 = @{ Id = "discord-api-key"; Pattern = '[a-zA-Z0-9_-]{32}\.[a-zA-Z0-9_-]{32}\.[a-zA-Z0-9_-]{32}' }
    35 = @{ Id = "discord-client-id"; Pattern = 'discord[0-9a-zA-Z]{16,}' }
    36 = @{ Id = "discord-client-secret"; Pattern = '[a-zA-Z0-9]{32}' }
    37 = @{ Id = "docker-personal-access-token"; Pattern = 'dckr_pat_[a-zA-Z0-9]{59}' }
    38 = @{ Id = "gcp-vertex-express-mode-key"; Pattern = 'vertex[0-9a-zA-Z]{32,}' }
    39 = @{ Id = "gitlab-cicd-job-token"; Pattern = 'glcbt-[0-9a-zA-Z]{20,}' }
    40 = @{ Id = "gitlab-deploy-token"; Pattern = 'gldt-[0-9a-zA-Z]{20,}' }
    41 = @{ Id = "gitlab-feature-flags-client-token"; Pattern = 'glffct-[0-9a-zA-Z]{20,}' }
}

$PatternCount = $Patterns.Count

# Allowed paths (for excluding files)
function Is-AllowedPath($file) {
    return $file -like "*.md"
}

# Mask secret - show first 4 and last 4 chars, mask the rest
function Mask-Secret($secret) {
    $len = $secret.Length
    if ($len -le 8) {
        return "****"
    }
    $prefix = $secret.Substring(0, 4)
    $suffix = $secret.Substring($len - 4, 4)
    $maskLen = $len - 8
    $mask = "*" * $maskLen
    return "${prefix}${mask}${suffix}"
}

# Track leaks
$Leaks = @()
$Seen = @{}

# Print banner
Write-Color "○" $Green
Write-Color "    │╲" $Green
Write-Color "    │ ○" $Green
Write-Color "    ○ ░" $Green
Write-Host "    ░    secret-scan"
Write-Host ""

# Handle staged-only mode (for pre-commit)
if ($staged) {
    $files = git diff --cached --name-only 2>$null
    if (-not $files) {
        Write-Color "No staged files to scan" $Yellow
        exit 0
    }

    foreach ($file in $files) {
        # Skip allowed paths
        if (Is-AllowedPath $file) {
            continue
        }

        # Get staged content
        $content = git show ":$file" 2>$null
        if (-not $content) {
            continue
        }

        # Check each pattern
        for ($i = 0; $i -lt $PatternCount; $i++) {
            $ruleId = $Patterns[$i].Id
            $pattern = $Patterns[$i].Pattern

            $matches = $content | Select-String -Pattern $pattern -AllMatches
            if ($matches) {
                foreach ($match in $matches) {
                    $lineNum = $match.LineNumber
                    $matchedText = $match.Match.Value
                    $fingerprint = "${file}:${ruleId}:${lineNum}"

                    # Skip if already seen (deduplicate)
                    if ($Seen.ContainsKey($fingerprint)) {
                        continue
                    }
                    $Seen[$fingerprint] = $true

                    $Leaks += $matchedText
                    $maskedMatch = Mask-Secret $matchedText
                    Write-Host ""
                    Write-Color "Finding:" $Red -NoNewline; Write-Host "     $maskedMatch"
                    Write-Color "RuleID:" $Yellow -NoNewline; Write-Host "      $ruleId"
                    Write-Color "File:" $Yellow -NoNewline; Write-Host "        $file"
                    Write-Color "Line:" $Yellow -NoNewline; Write-Host "        $lineNum"
                }
            }
        }
    }

    $leaksFound = $Leaks.Count

    if ($leaksFound -gt 0) {
        Write-Host "$(Get-Date -Format 'hh:mmtt') WRN leaks found: $leaksFound" -ForegroundColor $Yellow
        if ($exitCode -ne 0) {
            exit $exitCode
        }
    } else {
        Write-Host "$(Get-Date -Format 'hh:mmtt') INF no leaks found" -ForegroundColor $Green
    }

    exit 0
}

# Git history scan mode
$commits = git log $(if ($all) { "--all" }) --pretty=format:'%H' --reverse 2>$null

if (-not $commits) {
    Write-Color "No commits found to scan" $Yellow
    exit 0
}

$totalCommits = ($commits | Measure-Object).Count

# Scan each commit
foreach ($commit in $commits) {
    # Get files changed in this commit
    if (git rev-parse --verify "${commit}^" >$null 2>&1) {
        $files = git diff-tree --no-commit-id --name-only -r "$commit" 2>$null
    } else {
        $files = git ls-tree --name-only -r "$commit" 2>$null
    }

    foreach ($file in $files) {
        # Skip allowed paths
        if (Is-AllowedPath $file) {
            continue
        }

        # Get file content at this commit
        $content = git show "${commit}:${file}" 2>$null
        if (-not $content) {
            continue
        }

        # Check each pattern
        for ($i = 0; $i -lt $PatternCount; $i++) {
            $ruleId = $Patterns[$i].Id
            $pattern = $Patterns[$i].Pattern

            $matches = $content | Select-String -Pattern $pattern -AllMatches
            if ($matches) {
                foreach ($match in $matches) {
                    $lineNum = $match.LineNumber
                    $matchedText = $match.Match.Value
                    $fingerprint = "${file}:${ruleId}:${lineNum}"

                    # Skip if already seen (deduplicate)
                    if ($Seen.ContainsKey($fingerprint)) {
                        continue
                    }
                    $Seen[$fingerprint] = $true

                    $Leaks += $matchedText
                    $commitInfo = git log -1 --pretty=format:'%an|%ae|%ai' "$commit" 2>$null
                    $author, $email, $date = $commitInfo -split '\|'
                    $maskedMatch = Mask-Secret $matchedText
                    Write-Host ""
                    Write-Color "Finding:" $Red -NoNewline; Write-Host "     $maskedMatch"
                    Write-Color "RuleID:" $Yellow -NoNewline; Write-Host "      $ruleId"
                    Write-Color "File:" $Yellow -NoNewline; Write-Host "        $file"
                    Write-Color "Line:" $Yellow -NoNewline; Write-Host "        $lineNum"
                    Write-Color "Commit:" $Yellow -NoNewline; Write-Host "    $commit"
                    Write-Color "Author:" $Yellow -NoNewline; Write-Host "    $author"
                    Write-Color "Email:" $Yellow -NoNewline; Write-Host "     $email"
                    Write-Color "Date:" $Yellow -NoNewline; Write-Host "      $date"
                    if ($verbose) {
                        Write-Color "Fingerprint:" $Yellow -NoNewline; Write-Host " ${commit}:${file}:${ruleId}:${lineNum}"
                    }
                }
            }
        }
    }
}

Write-Host ""
Write-Host "$(Get-Date -Format 'hh:mmtt') INF $totalCommits commits scanned." -ForegroundColor $Green

$leaksFound = $Leaks.Count

if ($leaksFound -gt 0) {
    Write-Host "$(Get-Date -Format 'hh:mmtt') WRN leaks found: $leaksFound" -ForegroundColor $Yellow
    if ($exitCode -ne 0) {
        exit $exitCode
    }
} else {
    Write-Host "$(Get-Date -Format 'hh:mmtt') INF no leaks found" -ForegroundColor $Green
}

exit 0
