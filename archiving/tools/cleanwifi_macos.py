#!/usr/bin/python
import re
import plistlib
import subprocess

# get list of open network
lists = subprocess.Popen(["/usr/sbin/networksetup", "-listallhardwareports"], stdout=subprocess.PIPE).communicate()
lists = lists[0]

# search only for Wi-Fi device
try:
    interface = re.search('Wi-Fi\nDevice:\ (.+?)\n', lists).group(1)
    # get all known networks saved
    try:
        netw = plistlib.readPlist('/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist')
        netw = netw["KnownNetworks"]
    except:
        print("Plist is miss or nothing saved")
        quit()
except:
    print("No wireless, exist ...")
    quit()

opennet = []

print("-------- Networks lists --------")

for wifilst in netw:
    wifi = netw["{0}".format(wifilst)]
    print("[+] [Network {0}] - [Encryption: {1}]".format(wifi["SSID"].data, wifi["SecurityType"]))
    if (wifi["SecurityType"] == "Open"):
        opennet.append(wifi["SSID"].data)

if len(opennet):
    print("\n")
    print("------ Delete open network ------")
    print("---------------------------------")
    print("------ POPUPS IF NOT SUDO -------")
    print("---------------------------------")
    print("\n")

    for network in opennet:
        print("[-] Delete {}".format(network))
        subprocess.call(["/usr/sbin/networksetup", "-removepreferredwirelessnetwork", interface, network])