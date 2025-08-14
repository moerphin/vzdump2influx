# vzdump2influx
## Proxmox backup stats to InfluxDB ##

Just a simple script to wtite some stats to InfluxDB about your backup. Based on vzdump hook method.

Please don't hesitate, and contact me if you found a bug, or you have any idea for this script.

### Updates: ###
02/24/22: Tabnul's fixes (Thanks!) merged. Now it works with PVE 7.x, and requires InfluxDB 2.x (https://docs.influxdata.com/influxdb/v2.1/write-data/developer-tools/api/)

11/10/18: Quick fix for LXC transfer speeds

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
  - `<TOKEN>` : token for DB
  - `<ORGANIZATION>` : organization for DB
  - `<PROTOCOL>` : protocol for communication with DB server. HTTP or HTTPS
  - `<DBHOSTNAME>` : hostname or ip for your DB
  - `<PORT>` : HTTP API port (default: 8086)
  - `<BUCKETNAME>` : name of your bucket
  - `<LOCATIONCODE>` : put your location here. I have multiple DCs, so I have different location for each.
  - `DEBUG` : true or false. If the value is true, the script copies all logs to /tmp/timestamp (and does not delete it)

4. Add the hook to the backup job.
    Edit the /etc/vzdump.conf file, and add this line: "script: /location/of/the/script.sh"

5. Done!

    Thats all. :)
