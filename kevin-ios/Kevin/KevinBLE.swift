//
//  KevinBLE.swift
//  Kevin
//
//  Created by Michael Harper on 12/23/18.
//  Copyright © 2018 Michael Harper. All rights reserved.
//

import Foundation
import CoreBluetooth

let kevinServiceUUID = CBUUID(string: "A2F6EFEC-C2B1-7194-B247-7E5C3B754D5E")
let kevinRelayCharacteristicUUID = CBUUID(string: "A2F6EFEC-0001-7194-B247-7E5C3B754D5E")

class Kevin : NSObject, CBCentralManagerDelegate {
  static let shared = Kevin()
  
  static let relayValueKey = "relayValue"
  
  var centralManager: CBCentralManager!
  var kevinPeripheral: CBPeripheral?
  var relayCharacteristic: CBCharacteristic?
  var relayValue: Bool?
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
      
    case .unknown: ()
      
    case .resetting: ()
      
    case .unsupported: ()
      
    case .unauthorized: ()
      
    case .poweredOff: ()
      
    case .poweredOn:
      scanForKevin()
    }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    NotificationCenter.default.post(name: .didConnectToKevin, object: self)
    peripheral.delegate = self
    peripheral.discoverServices([kevinServiceUUID])
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    NotificationCenter.default.post(name: .didDisconnectFromKevin, object: self)
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)  {
    stopScanning()
    kevinPeripheral = peripheral
    connect(peripheral)
  }
  
  func initBluetooth() {
    centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
  }
  
  func scanForKevin() {
    centralManager.scanForPeripherals(withServices: [kevinServiceUUID], options:[CBCentralManagerScanOptionAllowDuplicatesKey: false])
  }
  
  func stopScanning() {
    centralManager.stopScan()
  }
  
  func connect(_ peripheral: CBPeripheral) {
    centralManager.connect(peripheral, options: nil)
  }
  
  func reconnect() {
    if let peripheral = kevinPeripheral {
      connect(peripheral)
    }
  }
  
  func disconnect() {
    if let peripheral = kevinPeripheral {
      centralManager.cancelPeripheralConnection(peripheral)
    }
  }
  
  func writeRelayCharacteristic(_ cameraOn: Bool) {
    if let characteristic = relayCharacteristic {
      kevinPeripheral?.writeValue(Data(bytes:[cameraOn ? UInt8(1) : UInt8(0)]), for: characteristic, type: .withResponse)
    }
  }
}

extension Kevin : CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let service = peripheral.services?[0] {
      peripheral.discoverCharacteristics([kevinRelayCharacteristicUUID], for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    relayCharacteristic = service.characteristics?[0]
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if characteristic == relayCharacteristic {
      NotificationCenter.default.post(name: .relayValueChanged, object: self, userInfo: [Kevin.relayValueKey : characteristic.value])
    }
  }
}

extension Notification.Name {
  static let didConnectToKevin = Notification.Name("didConnectToKevin")
  static let didDisconnectFromKevin = Notification.Name("didDisconnectFromKevin")
  static let relayValueChanged = Notification.Name("relayValueChanged")
}
