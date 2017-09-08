# escape=`
FROM microsoft/windowsservercore
ARG DOWNLOAD_URL
ARG AGENT_AUTH_KEY_ENCRYP

SHELL ["powershell", "-Command"]

#silent install app, clean up installer
ADD $DOWNLOAD_URL C:\
#ADD Spiceworks.exe C:\
RUN $args = \" /S \"; `
Start-Process C:\Spiceworks.exe -Wait -ArgumentList $args;
RUN Remove-Item C:\Spiceworks.exe -Force;

#set new http/https ports for app in registry, expose ports to docker
RUN New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_PORT\" -Value \"80\" -PropertyType String -Force | out-null; `
New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_HTTPS_PORT\" -Value \"443\" -PropertyType String -Force | out-null;
EXPOSE 80
EXPOSE 443

#update app to startup using registry defined http/https ports
WORKDIR "C:\\Program Files (x86)\\Spiceworks\\bin"
RUN Start-Process spiceworks.exe -Wait -NoNewWindow -ArgumentList httpdconf;

#set agent auth key, ruby -> sqlite
ADD ["set_agent_auth_key.rb", "C:/Program Files (x86)/Spiceworks/bin"]
WORKDIR "C:\\Program Files (x86)\\Spiceworks\\bin"
RUN $rubyArgs = \"set_agent_auth_key.rb \" + $Env:AGENT_AUTH_KEY_ENCRYP; `
Start-Process ruby.exe -Wait -NoNewWindow -ArgumentList $rubyArgs;

#startup and monitor app service, ref. https://github.com/MicrosoftDocs/Virtualization-Documentation/tree/master/windows-server-container-tools/Wait-Service
ADD Wait-Service.ps1 C:\Wait-Service.ps1
ENTRYPOINT powershell.exe -file c:\Wait-Service.ps1 -ServiceName spiceworks
