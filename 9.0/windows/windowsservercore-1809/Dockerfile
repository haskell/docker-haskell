FROM mcr.microsoft.com/windows/servercore:1809

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('C:\Program Files\ghc\bin;C:\Program Files\cabal-install;C:\Program Files\stack;{0}' -f $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

RUN $cabalInstallVersion = '3.6.2.0'; \
    $url = ('https://downloads.haskell.org/~cabal/cabal-install-{0}/cabal-install-{0}-x86_64-windows.zip' -f $cabalInstallVersion); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'cabal-install.zip'; \
	\
	$sha256 = '89aa3aa3f76d15182c0d03227639890cd537627ba0bf0ef9ab451fee504b24c6'; \
	Write-Host ('Verifying sha256 ({0}) ...' -f $sha256); \
	if ((Get-FileHash cabal-install.zip -Algorithm sha256).Hash -ne $sha256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive cabal-install.zip -DestinationPath C:\cabal-install; \
	\
	Write-Host 'Moving ...'; \
	Move-Item -Path 'C:\cabal-install' -Destination 'C:\Program Files\cabal-install'; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item cabal-install.zip -Force; \
    \
	Write-Host 'Verifying install ("cabal --version") ...'; \
	cabal --version; \
	\
	Write-Host 'Complete.';    

RUN $ghcVersion = '9.0.2'; \
    $releaseName = ('ghc-{0}-x86_64-unknown-mingw32' -f $ghcVersion); \
    $url = ('https://downloads.haskell.org/~ghc/{0}/{1}.zip' -f $ghcVersion, $releaseName); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'ghc.zip'; \
	\
	$sha256 = 'ddd22abb7e6731506320585bffa11a4182fd6b4f9751111a588409568fd95d9f'; \
	Write-Host ('Verifying sha256 ({0}) ...' -f $sha256); \
	if ((Get-FileHash ghc.zip -Algorithm sha256).Hash -ne $sha256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive ghc.zip -DestinationPath C:\; \
	\
	Write-Host 'Moving ...'; \
	Move-Item -Path ('C:\{0}' -f $releaseName) -Destination 'C:\Program Files\ghc'; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item ghc.zip -Force; \
	\
	Write-Host 'Verifying install ("ghc --version") ...'; \
	ghc --version; \
	\
	Write-Host 'Complete.';

RUN $stackVersion = '2.7.3'; \
    $url = ('https://github.com/commercialhaskell/stack/releases/download/v{0}/stack-{0}-windows-x86_64.zip' -f $stackVersion); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'stack.zip'; \
	\
	$sha256 = '9f8c406f5ffbe72670c9499959ddab76fa8a378b4f25e3b82700c16c7fd2bad6'; \
	Write-Host ('Verifying sha256 ({0}) ...' -f $sha256); \
	if ((Get-FileHash stack.zip -Algorithm sha256).Hash -ne $sha256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive stack.zip -DestinationPath C:\stack; \
	\
	Write-Host 'Moving ...'; \
    # Manually create the directory and just copy the exe, we don't want the docs
    New-Item -Path 'C:\Program Files' -Name 'stack' -ItemType 'directory'; \
	Move-Item -Path 'C:\stack\stack.exe' -Destination 'C:\Program Files\stack\stack.exe'; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item stack.zip -Force; \
    Remove-Item -Path 'C:\stack' -Recurse -Force; \
    \
	Write-Host 'Verifying install ("stack --version") ...'; \
	stack --version; \
	\
	Write-Host 'Complete.';  

CMD ["ghci"]