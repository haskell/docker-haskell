FROM mcr.microsoft.com/windows/servercore:1809

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install MinGit (cabal + stack can have git dependencies)
# Pinned so we can sha256 verify, but this should only be bumped when something else is being bumped.
# https://blogs.msdn.microsoft.com/visualstudioalm/2016/09/03/whats-new-in-git-for-windows-2-10/
# "Essentially, it is a Git for Windows that was stripped down as much as possible without sacrificing the functionality in which 3rd-party software may be interested."
# "It currently requires only ~45MB on disk."
ARG GIT_VERSION=2.23.0
ARG GIT_DOWNLOAD_SHA256=8f65208f92c0b4c3ae4c0cf02d4b5f6791d539cd1a07b2df62b7116467724735
# steps inspired by "chcolateyInstall.ps1" from "git.install" (https://chocolatey.org/packages/git.install)
RUN $url = ('https://github.com/git-for-windows/git/releases/download/v{0}.windows.1/MinGit-{0}-64-bit.zip' -f $env:GIT_VERSION); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'git.zip'; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:GIT_DOWNLOAD_SHA256); \
	if ((Get-FileHash git.zip -Algorithm sha256).Hash -ne $env:GIT_DOWNLOAD_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive -Path git.zip -DestinationPath C:\git\.; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item git.zip -Force; \
	\
	Write-Host 'Updating PATH ...'; \
	$env:PATH = 'C:\git\cmd;C:\git\mingw64\bin;C:\git\usr\bin;' + $env:PATH; \
	[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); \
	\
	Write-Host 'Verifying install ("git version") ...'; \
	git version; \
	\
	Write-Host 'Complete.';

# Try this
ARG MSYS2_VERSION=2022-06-03
ARG MSYS2_SHA256=0694bf6661aa9dae8338be87b633ae9ac20c68d593cc17658a1dffe6291098bf

RUN $collapsedVersion = $env:MSYS2_VERSION -replace '-','';\
	# $url = ('https://github.com/msys2/msys2-installer/releases/download/{0}/msys2-base-x86_64-{1}.sfx.exe' -f $env:MSYS2_VERSION, $collapsedVersion); \
	$url = 'https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe'; \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'msys2.exe'; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:MSYS2_SHA256); \
	if ((Get-FileHash msys2.exe -Algorithm sha256).Hash -ne $env:MSYS2_SHA256) { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Installing ...'; \
	.\msys2.exe -y -oC:\; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item msys2.exe -Force; \
	\
	Write-Host 'Configure + Verify...'; \
	function msys() { C:\msys64\usr\bin\bash.exe @('-lc') + @Args; } \
	msys ' '; \
	# Upgrading full system...
	msys 'pacman --noconfirm -Syuu'; \
	# Upgrading full system twice...
	msys 'pacman --noconfirm -Syuu'; \
	# Installing Haskell Dependencies...
	msys 'pacman --noconfirm -S --needed curl autoconf mingw-w64-x86_64-pkgconf'; \
	# Updating SSL root certificate authorities...
	msys 'pacman --noconfirm -S ca-certificates'; \
	# Clean up the cache...
	msys 'pacman --noconfirm -Scc'; \
	\
	Write-Host 'Complete.';
# https://gitlab.haskell.org/haskell/ghcup-hs/-/blob/master/scripts/bootstrap/bootstrap-haskell.ps1#L428-435 ?

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('C:\Program Files\ghc\bin;C:\Program Files\cabal-install;C:\Program Files\stack;{0}' -f $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

ARG CABAL_INSTALL_VERSION=3.8.1.0
ARG CABAL_INSTALL_SHA256=b6dd6afe0e5a883f84dc52d836af0e90d9cd2b2978dd87200332085ecb4a0315

RUN $url = ('https://downloads.haskell.org/~cabal/cabal-install-{0}/cabal-install-{0}-x86_64-windows.zip' -f $env:CABAL_INSTALL_VERSION); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'cabal-install.zip'; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:CABAL_INSTALL_SHA256); \
	if ((Get-FileHash cabal-install.zip -Algorithm sha256).Hash -ne $env:CABAL_INSTALL_SHA256) { \
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

ARG STACK_VERSION=2.7.5
ARG STACK_SHA256=a77a1b27501d78800baa7e88d8ccca1d6e9b19b9c59f02f2a40ca260aaa75260

RUN $url = ('https://github.com/commercialhaskell/stack/releases/download/v{0}/stack-{0}-windows-x86_64.zip' -f $env:STACK_VERSION); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'stack.zip'; \
	\
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:STACK_SHA256); \
	if ((Get-FileHash stack.zip -Algorithm sha256).Hash -ne $env:STACK_SHA256) { \
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
	Write-Host 'Configure ...'; \
	stack config set system-ghc --global true; \
	stack config set install-ghc --global false; \
	\
	Write-Host 'Verifying install ("stack --version") ...'; \
	stack --version; \
	\
	Write-Host 'Complete.';

ARG GHC_VERSION=9.0.2
ARG GHC_SHA256=ddd22abb7e6731506320585bffa11a4182fd6b4f9751111a588409568fd95d9f

RUN $releaseName = ('ghc-{0}-x86_64-unknown-mingw32' -f $env:GHC_VERSION); \
    $url = ('https://downloads.haskell.org/~ghc/{0}/{1}.zip' -f $env:GHC_VERSION, $releaseName); \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'ghc.zip'; \
	\
	$sha256 = 'ddd22abb7e6731506320585bffa11a4182fd6b4f9751111a588409568fd95d9f'; \
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:GHC_SHA256); \
	if ((Get-FileHash ghc.zip -Algorithm sha256).Hash -ne $env:GHC_SHA256) { \
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

CMD ["ghci"]
