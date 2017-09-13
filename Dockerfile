# escape=`
FROM microsoft/windowsservercore
ARG DOWNLOAD_URL
ARG AGENT_AUTH_KEY_ENCRYP
ARG HTTP_PORT
ARG HTTPS_PORT

SHELL ["powershell", "-Command"]

#silent install app, clean up installer
ADD $DOWNLOAD_URL C:\
#ADD Spiceworks.exe C:\
RUN $args = \" /S \"; `
Start-Process C:\Spiceworks.exe -Wait -ArgumentList $args;
RUN Remove-Item C:\Spiceworks.exe -Force;

#set new http/https ports for app in registry, expose ports to docker
RUN New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_PORT\" -Value \"$Env:HTTP_PORT\" -PropertyType String -Force | out-null; `
New-ItemProperty -Path \"HKLM:\SOFTWARE\Wow6432Node\Spiceworks\" -Name \"SPICE_HTTPS_PORT\" -Value \"$Env:HTTPS_PORT\" -PropertyType String -Force | out-null;
EXPOSE $HTTP_PORT
EXPOSE $HTTPS_PORT

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

#web app responsive = container up/healthy
HEALTHCHECK CMD powershell -command `  
    try { `
     $HTTP_PORT = $Env:HTTP_PORT; `
     $response = iwr http://localhost:$HTTP_PORT -UseBasicParsing; `
     if ($response.StatusCode -eq 200) { return 0} `
     else {return 1}; `
    } catch { return 1 }
