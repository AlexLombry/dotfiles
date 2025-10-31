#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Airpods Pro Toogle
// @raycast.mode silent

// Optional parameters:
// @raycast.icon images/airpod.png
// @raycast.packageName audio

// Documentation:
// @raycast.description Connect my AirPods Max
// @raycast.author Alex Lombry
import IOBluetooth

// Get your device's MAC address by option (⌥) + clicking the bluetooth icon in the menu bar
let deviceAddress = "74-15-F5-4F-A8-65"

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
}

toggleAirPods()