# escape=`
FROM microsoft/windowsservercore
ARG DOWNLOAD_URL

ADD $DOWNLOAD_URL C:\

SHELL ["powershell", "-Command"]

#silent install app
RUN $args = \" /S \"; `
Start-Process C:\Spiceworks.exe -Wait -ArgumentList $args;

#set new http/https ports in registry
RUN New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_PORT\" -Value \"80\" -PropertyType String -Force; `
New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_HTTPS_PORT\" -Value \"443\" -PropertyType String -Force;

#update app with new startup http/https ports
RUN $args = \" httpdconf \"; `
Start-Process \"C:\Program Files (x86)\Spiceworks\bin\spiceworks.exe\" -Wait -ArgumentList $args;

#startup app
RUN Start-Service spiceworks;

#allow inbound http/https traffic to container
EXPOSE 80
EXPOSE 443

#delete app installer
RUN Remove-Item C:\Spiceworks.exe -Force;
