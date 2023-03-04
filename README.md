# UDM-MTU
A script to set the MTU value on a Ubiquiti UDM-PRO when using PPPoE

The sciprt setMTU.sh takes in 1 argument, which is the desired MTU value (ETH_MTU) for your WAN connection (not your ppp interface). 

* It will automatically calculate the appropriate MSS value based on the provided MTU value (ETH_MTU-40)
* It will automatically calculate the appropriate MTU value for the ppp interface (ETH_MTU+8)
* It will automatically detect the appropriate network interface to adjust the MTU value for. 
- This may not always be accurate and you may need to modify the script if you are using multiple WAN connections or VLAN, this script has not been tested with either. Please submit a pull request if you do that to harden/enhance this script.
- This is determined by looking at the 2nd line of /etc/ppp/peers/ppp0 and seeing the listed interface name.
-- My assumption if you have multiple PPPoE WAN connections setup is that you have an additional /etc/ppp/peers/ppp1 file that woud need this logic mirrored against but I have never tested this.

What it changes
1. The file /etc/ppp/peers/ppp0
 - Changes both the MTU and MRU values to the value of the first provided argument of the script
2. iptables value for MSS
 - This is being done because the UDM-PRO web interface to set the MSS value for the device was not working for me. It was inconsistent at best and wrong most of the time. So I set the value directly instead
 - You can see this using the command `iptables -L -t mangle --line-numbers` and looking for UBIOS_FORWARD_TCPMSS
 - This also deletes the first 2 existing entries for UBIOS_FORWARD_TCPMSS. I do this because my setup automatically had 2 identical rules setup whenever it restarts or changes settings.
3. ETH network interface MTU value
 - The detected interface from /etc/ppp/peers/ppp0 will have its MTU value changes to the inputted MTU value +8. so if you run the script ./setMTU 1500 this will be set to 1508 the extra 8 is to account for the additional 8 byte overhead of PPPoE
4. Takes down the ETH network interface and brings it back up. Then kills the pppd process, so that it will automatically restart itself

Example Usage:
./setMTU.sh 1444
   This will set your WAN connection to have a MTU value of 1444. This is what I have mine set to because my ISP has a lower MTU for some reason
./setMTU.sh 1500
   This will likely be the most common use, to correct for the default udm-pro value of 1492 which is not adjustable in the settings
