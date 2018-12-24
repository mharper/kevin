//
//  ViewController.swift
//  Kevin
//
//  Created by Michael Harper on 12/23/18.
//  Copyright © 2018 Michael Harper. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
  var centralManager: CBCentralManager!
  var kevinPeripheral: CBPeripheral?
  var relayCharacteristic: CBCharacteristic?
  
  @IBOutlet weak var toggleCameraButton: UIButton!
  var cameraOn = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    initBluetooth()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    disconnect()
  }
  
  func scanForKevin() {
    centralManager.scanForPeripherals(withServices: [kevinServiceUUID], options:[CBCentralManagerScanOptionAllowDuplicatesKey: false])
  }
  
  @IBAction func toggleAction(_ sender: Any) {
    cameraOn = !cameraOn
    writeRelayCharacteristic(cameraOn)
  }
}

extension ViewController : CBCentralManagerDelegate {
  func initBluetooth() {
    centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
  }

  func disconnect() {
    if let peripheral = kevinPeripheral {
      centralManager.cancelPeripheralConnection(peripheral)
    }
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
      
    case .unknown: ()
      
    case .resetting: ()
      
    case .unsupported:
      let alert = UIAlertController(title: "Bluetooth Unsupported", message: "Bluetooth is not supported on this device.", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "Bummer", style: .default, handler: nil)
      alert.addAction(okAction)
      present(alert, animated: true, completion: nil)
      
    case .unauthorized: ()
      
    case .poweredOff: ()
    let alert = UIAlertController(title: "Bluetooth Turned Off", message: "Please turn Bluetooth on so that the app can scan for beacons.", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
      
    case .poweredOn: ()
      scanForKevin()
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)  {
    kevinPeripheral = peripheral
    central.connect(peripheral, options: nil)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.delegate = self
    peripheral.discoverServices([kevinServiceUUID])
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
  }
}

extension ViewController : CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let service = peripheral.services?[0] {
      peripheral.discoverCharacteristics([kevinRelayCharacteristicUUID], for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    relayCharacteristic = service.characteristics?[0]
    toggleCameraButton.isEnabled = (relayCharacteristic != nil)
  }
  
  func writeRelayCharacteristic(_ cameraOn: Bool) {
    if let characteristic = relayCharacteristic {
      kevinPeripheral?.writeValue(Data(bytes:[cameraOn ? UInt8(0) : UInt8(1)]), for: characteristic, type: .withResponse)
    }
  }
}
