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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initBluetooth()
  }
  
  func scanForKevin() {
    centralManager.scanForPeripherals(withServices: [kevinServiceUUID], options:[CBCentralManagerScanOptionAllowDuplicatesKey: false])
  }
}

extension ViewController : CBCentralManagerDelegate {
  func initBluetooth() {
    centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
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
    NSLog("Found peripheral: \(peripheral.identifier)")
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
  }
}
