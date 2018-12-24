//
//  Kevinable.swift
//  Kevin
//
//  Created by Michael Harper on 12/24/18.
//  Copyright © 2018 Michael Harper. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol Kevinable {
  var centralManager: CBCentralManager! { get set }
  var kevinPeripheral: CBPeripheral? { get set }
  var relayCharacteristic: CBCharacteristic? { get set }
}
