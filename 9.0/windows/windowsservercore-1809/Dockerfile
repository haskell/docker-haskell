FROM mcr.microsoft.com/windows/servercore:1809

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('{0}\bin;C:\Program Files\ghc\bin;{1}' -f $env:GOPATH, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

RUN $url = 'https://downloads.haskell.org/~ghc/9.0.2/ghc-9.0.2-x86_64-unknown-mingw32.zip'; \
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
	Move-Item -Path C:\ghc-9.0.2-x86_64-unknown-mingw32 -Destination 'C:\Program Files\ghc'; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item ghc.zip -Force; \
	\
	Write-Host 'Verifying install ("ghc --version") ...'; \
	ghc --version; \
	\
	Write-Host 'Complete.';

CMD ["ghci"]