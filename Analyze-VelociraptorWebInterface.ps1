# Analyze Velociraptor Web Interface
param(
    [string]$BaseUrl = "https://127.0.0.1:8889",
    [string]$OutputDir = "velociraptor-analysis"
)

# Create output directory
if (!(Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force
}

Write-Host "Analyzing Velociraptor Web Interface at $BaseUrl" -ForegroundColor Green

# Common pages to analyze
$pages = @(
    "/",
    "/app/index.html",
    "/static/css/",
    "/static/js/",
    "/api/v1/GetServerMetadata",
    "/api/v1/GetArtifacts",
    "/api/v1/GetArtifactFile",
    "/app/hunts.html",
    "/app/artifacts.html",
    "/app/notebooks.html",
    "/app/users.html",
    "/app/host_info.html"
)

# Function to make HTTP request and save response
function Get-PageContent {
    param(
        [string]$Url,
        [string]$OutputFile
    )
    
    try {
        Write-Host "Fetching: $Url" -ForegroundColor Yellow
        
        $response = Invoke-WebRequest -Uri $Url -SkipCertificateCheck -UseBasicParsing -ErrorAction SilentlyContinue
        
        if ($response) {
            $content = $response.Content
            $headers = $response.Headers
            
            # Save content
            $content | Out-File -FilePath $OutputFile -Encoding UTF8
            
            # Save headers
            $headerFile = $OutputFile -replace "\.html$", "_headers.txt" -replace "\.css$", "_headers.txt" -replace "\.js$", "_headers.txt"
            $headers | Out-File -FilePath $headerFile -Encoding UTF8
            
            Write-Host "  Saved: $OutputFile (Size: $($content.Length) bytes)" -ForegroundColor Green
            
            return $response
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Analyze each page
foreach ($page in $pages) {
    $url = "$BaseUrl$page"
    $filename = ($page -replace "/", "_" -replace ":", "_") + ".html"
    if ($filename -eq "_.html") { $filename = "index.html" }
    
    $outputFile = Join-Path $OutputDir $filename
    $response = Get-PageContent -Url $url -OutputFile $outputFile
}