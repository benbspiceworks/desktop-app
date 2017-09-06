# escape=`
FROM microsoft/windowsservercore
ARG DOWNLOAD_URL

SHELL ["powershell", "-Command"]

#silent install app
ADD $DOWNLOAD_URL C:\
#ADD Spiceworks.exe C:\
RUN $args = \" /S \"; `
Start-Process C:\Spiceworks.exe -Wait -ArgumentList $args;

#set new http/https ports in registry
RUN New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_PORT\" -Value \"80\" -PropertyType String -Force; `
New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_HTTPS_PORT\" -Value \"443\" -PropertyType String -Force;

WORKDIR "C:\\Program Files (x86)\\Spiceworks\\bin"

#update app with new startup http/https ports
RUN Start-Process spiceworks.exe -Wait -NoNewWindow -ArgumentList httpdconf;

#set agent auth key
ADD ["set_agent_auth_key.rb", "C:/Program Files (x86)/Spiceworks/bin"]
RUN Start-Process ruby.exe -Wait -NoNewWindow -ArgumentList set_agent_auth_key.rb;

#startup app
RUN Start-Service spiceworks;

#allow inbound http/https traffic to container
EXPOSE 80
EXPOSE 443

#delete app installer
RUN Remove-Item C:\Spiceworks.exe -Force;
