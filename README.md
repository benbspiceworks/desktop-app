# desktop-app

`docker run -dit -p 80:80 -p 443:443 --name spiceworks benbspiceworks/desktop-app`

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
