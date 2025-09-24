#FROM mcr.microsoft.com/powershell:lts-alpine-3.10
FROM mcr.microsoft.com/dotnet/sdk:9.0

COPY LICENSE README.md /

RUN mkdir -p /usr/local/share/powershell/Modules/OSZipper
RUN mkdir -p /usr/local/share/powershell/Modules/DocumentationManager
RUN mkdir -p /usr/local/share/powershell/Modules/StringsManager

COPY ./utils/OSZipper.psm1 /usr/local/share/powershell/Modules/OSZipper/OSZipper.psm1
COPY ./utils/DocumentationManager.psm1 /usr/local/share/powershell/Modules/DocumentationManager/DocumentationManager.psm1
COPY ./utils/StringsManager.psm1 /usr/local/share/powershell/Modules/StringsManager/StringsManager.psm1

COPY entrypoint.ps1 /entrypoint.ps1

#RUN pwsh -c "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force"

ENTRYPOINT ["pwsh", "-Command", "/entrypoint.ps1"]
