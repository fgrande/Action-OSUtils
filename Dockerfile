FROM mcr.microsoft.com/powershell:lts-alpine-3.10

COPY LICENSE README.md /

COPY ./utils/*.ps* ./usr/local/share/powershell/Modules

COPY entrypoint.ps1 /entrypoint.ps1

ENTRYPOINT ["pwsh", "-Command", "/entrypoint.ps1"]
