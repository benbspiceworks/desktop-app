# desktop-app-core

Use docker to build a container that installs and runs the Spiceworks Desktop app.

## Initial Setup
This can likely be done in any VirtualBox host. In macOS/Sierra (10.12):
  * install latest VirtualBox
  * Create a 2016 Server VM within VirtualBox

In the Server 2016 VM:
  * Install latest Docker
  * Pull down Windows server core from docker:  
  `docker pull microsoft/windowsservercore` (this should be vanilla Server 2016 with .Net 4.5)

## Example docker build command

Ex. docker build command where Dockerfile is stored at c:\build\Dockerfile

`docker build -t benbspiceworks/desktop-app c:\build --build-arg DOWNLOAD_URL="http://download.spiceworks.com/Spiceworks/beta/Spiceworks.exe" --build-arg AGENT_AUTH_KEY_ENCRYP="actualEncryptedKey"`

You can also use `http://download.spiceworks.com/Spiceworks.exe` for the production release branch. 

Pull the encrypted key value from `configuration.name="remote_agent_key"` in /db/spiceworks_prod.db, after you've spun up an app and set the authorization key manually in the Inventory web UI. If you enter `spiceworks` to set the key in the Inventory web UI, your encrypted key will look something like `Tvbum4Xqk/cxxx/kTxxxxJAuSr8=`. You can also use the example command as is, and reset the key using the Inventory web UI later.

## View images 
`docker images`

## Run the new image in a container

`docker run -dit -p 80:80/tcp -p 443:443/tcp --name desktopapp --hostname desktopapp benbspiceworks/desktop-app-core
`

The container is launched in the background with interactive mode enabled, which means we can "attach" to the container's console.

## Allow host OS to access container running Spiceworks Desktop app

Open up your Server 2016 VM's Windows firewall:

`Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False`

Now any traffic to the Server 2016 VM will route through to internal services running on the Server 2016 VM. In this case, your Server 2016 VM has a container running Spiceworks Desktop app on 80/443, and have exposed the container's 80/443 ports to the Server 2016 VM. So we just need to route traffic from the macOS host, into the Server 2016 VM (which will automatically route into the container).

Be sure you have a "host only" network interface setup in the host VirtualBox configuration for your Server 2016 VM:

![vm-netadapter](https://github.com/benbspiceworks/desktop-app/raw/master/Screen%20Shot%202017-08-28%20at%2011.23.46%20AM.png)

Now, from the console of the Server 2016 VM, run `ipconfig` to find the VM interface's IP address for this host-only NIC.
You can use the VM interface's IP address to access the container's web service (Spiceworks Desktop) from the host OS (macOS).

  > macOS (host) → Server 2016 VM → container → Spiceworks Desktop app service

My Server 2016 VM's host-only interface IP was 192.168.99.101. So I can access Spiceworks from http://192.168.99.101/ in Safari in macOS.

## Lookup the name of the container (its dynamic)
`docker ps -a`

## Check Spiceworks db values
You can use this command to execute arbitrary SQL commands against the database. 

For example, the below command will output a list of SQL records which should include the auth key record "remote_agent_key" because the container build process automatically sets the key to allow agents to checkin without going through the normal process of using the Desktop app web UI to set the key. 

`docker exec desktopapp "C:\Program Files (x86)\Spiceworks\bin\sqlite3.exe" "C:\Program Files (x86)\Spiceworks\db\spiceworks_prod.db" "SELECT * FROM configuration WHERE name LIKE 'remote_agent%';"`
 
## Check Desktop app logs
`docker exec desktopapp powershell -command {cat "C:\Program Files (x86)\Spiceworks\log\production.log"}`
