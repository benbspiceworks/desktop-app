# escape=`
FROM microsoft/windowsservercore

ADD https://download.spiceworks.com/Spiceworks.exe C:\

SHELL ["powershell", "-Command"]

RUN $args = \" /S \"; `
Start-Process C:\Spiceworks.exe -Wait -ArgumentList $args;

RUN New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_PORT\" -Value \"80\" -PropertyType String -Force; `
New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_HTTPS_PORT\" -Value \"443\" -PropertyType String -Force; 

RUN $args = \" httpdconf \"; `
Start-Process \"C:\Program Files (x86)\Spiceworks\bin\spiceworks.exe\" -Wait -ArgumentList $args;

RUN Start-Service spiceworks;

EXPOSE 80
EXPOSE 443

RUN Remove-Item C:\Spiceworks.exe -Force;
