//
//  ViewController.swift
//  Kevin
//
//  Created by Michael Harper on 12/23/18.
//  Copyright © 2018 Michael Harper. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, Kevinable {
  var centralManager: CBCentralManager!
  var kevinPeripheral: CBPeripheral?
  var relayCharacteristic: CBCharacteristic?
  
  @IBOutlet weak var toggleCameraButton: UIButton!
  @IBOutlet weak var connectDisconnectButton: UIButton!
  
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
  
  @IBAction func toggleAction(_ sender: Any) {
    cameraOn = !cameraOn
    writeRelayCharacteristic(cameraOn)
  }
  
  @IBAction func connectDisconnectAction(_ sender: Any) {
    if let kevinPeripheral = kevinPeripheral {
      switch kevinPeripheral.state {
      case .connected, .connecting:
        disconnect()
      case .disconnected, .disconnecting:
        connect(kevinPeripheral)
      default: ()
      }
    }
  }
  
  func configureConnectButton() {
    DispatchQueue.main.async {
      switch self.kevinPeripheral?.state {
      case .connected?, .connecting?:
        self.connectDisconnectButton.setTitle("Disconnect", for: .normal)
        self.connectDisconnectButton.setTitleColor(UIColor.white, for: .normal)
        self.connectDisconnectButton.backgroundColor = UIColor.blue
        
      case .disconnected?, .disconnecting?:
        self.connectDisconnectButton.setTitle("Connect", for: .normal)
        self.connectDisconnectButton.setTitleColor(UIColor.blue, for: .normal)
        self.connectDisconnectButton.backgroundColor = UIColor.white
        
      default: ()
      }
    }
  }
}

extension ViewController : CBCentralManagerDelegate {  
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
    connect(peripheral)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.delegate = self
    peripheral.discoverServices([kevinServiceUUID])
    configureConnectButton()
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    configureConnectButton()
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
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if characteristic == relayCharacteristic {
      
    }
  }
  
}
