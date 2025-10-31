#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Airpods Max Toogle
// @raycast.mode silent

// Optional parameters:
// @raycast.icon 🎧
// @raycast.packageName audio

// Documentation:
// @raycast.description Connect my AirPods Max
// @raycast.author Alex Lombry

print("Hello World!")

import IOBluetooth

// Get your device's MAC address by option (⌥) + clicking the bluetooth icon in the menu bar
let deviceAddress = "90-9C-4A-EE-3F-9F"

func toggleAirPods() {
    guard let bluetoothDevice = IOBluetoothDevice(addressString: deviceAddress) else {
        print("Device not found")
        exit(1)
    }

    if !bluetoothDevice.isPaired() {
        print("Device not paired")
        exit(1)
    }

    if bluetoothDevice.isConnected() {
        print("AirPods Disconnected")
        bluetoothDevice.closeConnection()
    } else {
        print("AirPods Connected")
        bluetoothDevice.openConnection()
    }

    print("End of script")
}

toggleAirPods()
