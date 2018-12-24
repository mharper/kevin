//
//  Kevinable.swift
//  Kevin
//
//  Created by Michael Harper on 12/24/18.
//  Copyright © 2018 Michael Harper. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol Kevinable : class {
  var centralManager: CBCentralManager! { get set }
  var kevinPeripheral: CBPeripheral? { get set }
  var relayCharacteristic: CBCharacteristic? { get set }
  
  func initBluetooth()
  func connect(_ peripheral: CBPeripheral)
  func disconnect()
  func writeRelayCharacteristic(_ cameraOn: Bool)
}

extension Kevinable where Self : CBCentralManagerDelegate {
  func initBluetooth() {
    centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
  }
  
  func connect(_ peripheral: CBPeripheral) {
    centralManager.connect(peripheral, options: nil)
  }
  
  func disconnect() {
    if let peripheral = kevinPeripheral {
      centralManager.cancelPeripheralConnection(peripheral)
    }
  }
  
  func writeRelayCharacteristic(_ cameraOn: Bool) {
    if let characteristic = relayCharacteristic {
      kevinPeripheral?.writeValue(Data(bytes:[cameraOn ? UInt8(0) : UInt8(1)]), for: characteristic, type: .withResponse)
    }
  }
}
