# vzdump2influx
## Proxmox backup stats to InfluxDB ##

Just a simple script to wtite some stats to InfluxDB about your backup. Based on vzdump hook method.

Please don't hesitate, and contact me if you found a bug, or you have any idea for this script.

### Requirements: ###
- Proxmox :)
- curl

### Install: ###
1. On Proxmox host install curl.

    `sudo apt-get install curl`
  
2. Put the script somewhere.

    E.g. /usr/local/bin/vzdump2influx.sh
  
    Be sure your script is executable. (Check the permissions on file.)
  
3. Customize!
  
  Fill the neccessary datas in the script.
  - `<DBUSER>` : username for DB
  - `<DBPASS>` : password for DB
  - `<DBHOST>` : hostname or ip for your DB
  - `<DBPORT>` : HTTP API port (default: 8086)
  - `<DBNAME>` : name of your DB
  - `<LOCATION_CODE>` : put your location here. I have multiple DCs, so I have different location for each.

4. Add the hook to the backup job.
    Edit the /etc/vzdump.conf file, and add this line: "script: /location/of/the/script.sh"

5. Done!

    Thats all. :)
