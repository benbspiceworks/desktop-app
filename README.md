# desktop-app

Use docker to build a container that installs and runs the Spiceworks Desktop app.

## Initial Setup
This can likely be done in any VirtualBox host, but in macOS/Sierra (10.12)
  * install latest VirtualBox
  * Create a 2016 Server VM within VirtualBox

In the Server 2016 VM:
  * Install latest Docker
  * Pull down Windows server core from docker:  
  `docker pull microsoft/windowsservercore` (this should be vanilla Server 2016 with .Net 4.5)
 
Note: looks like MSI requires WindowsServerCore, and can't be done with NanoServer. 
ref. https://blog.sixeyed.com/how-to-dockerize-windows-applications/ 

## Example docker build command

Ex. docker build command where Dockerfile is stored at c:\build\Dockerfile

`docker build -t desktop-app c:\build`

After a successful build:

## View images 
`docker images`

## Run the new image in a container

`docker run -dit -p 80:80 -p 443:443 --name spiceworks benbspiceworks/desktop-app`

The container is launched in the background with interactive mode enabled, which means we can "attach" to the container's console.

## Allow host OS to access container running Spiceworks Desktop app

Open up your Server 2016 VM's Windows firewall:

`Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False`

Now any traffic to the Server 2016 VM will route through to internal services running on the Server 2016 VM. In this case, your Server 2016 VM has a container running Spiceworks Desktop app on 80/443, and have exposed the container's 80/443 ports to the Server 2016 VM. So we just need to route traffic from the macOS host, into the Server 2016 VM (which will automatically route into the container).

Be sure you have a "host only" network interface setup in the host VirtualBox configuration for your Server 2016 VM:

Support > Test Env./Containers > Screen Shot 2017-08-28 at 11.23.46 AM.png

Now, from the console of the Server 2016 VM, run ipconfig to find the VM interface's IP address for this host-only NIC.
You can use the VM interface's IP address to access the container's web service (Spiceworks Desktop) from the host OS (macOS).

macOS (host) → Server 2016 VM → container → Spiceworks Desktop app service

My Server 2016 VM's host-only interface IP was 192.168.99.101. So I can access Spiceworks from http://192.168.99.101/ in Safari in macOS.

## Lookup the name of the container (its dynamic)
`docker ps -a`
 
## Then attach to the console using
`docker attach <dynamic name>`
 
After running docker attach you'll have a cmd console. You can call powershell to get a PS console.
You can detach and leave the container running using Ctrl+P , Ctrl+Q.
