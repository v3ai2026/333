
try {
    docker build -t magicai-test -f "c:\Users\Administrator\Desktop\MagicAI v9.9\MagicAI v9.9\Dockerfile" "c:\Users\Administrator\Desktop\MagicAI v9.9\MagicAI v9.9"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker image built successfully."
        docker rmi magicai-test
        exit 0
    } else {
        Write-Host "Docker build failed."
        exit 1
    }
} catch {
    Write-Host "An error occurred during Docker build: $_"
    exit 1
}
