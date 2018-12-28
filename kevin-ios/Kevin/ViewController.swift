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
  @IBOutlet weak var toggleCameraButton: UIButton!
  @IBOutlet weak var connectDisconnectButton: UIButton!
  
  var cameraOn = false
  
  let kevin = Kevin.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerForNotifications()
    configureConnectButton()
  }
  
  @IBAction func toggleAction(_ sender: Any) {
    cameraOn = !cameraOn
    kevin.writeRelayCharacteristic(cameraOn)
  }
  
  @IBAction func connectDisconnectAction(_ sender: Any) {
    if let kevinPeripheral = kevin.kevinPeripheral {
      switch kevinPeripheral.state {
      case .connected, .connecting:
        kevin.disconnect()
      case .disconnected, .disconnecting:
        kevin.reconnect()
      default: ()
      }
    }
  }
  
  func registerForNotifications() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(forName: Notification.Name.didConnectToKevin, object: nil, queue: nil) { (notification) in
      self.configureConnectButton()
      self.configureToggleButton()
    }
    notificationCenter.addObserver(forName: Notification.Name.didDisconnectFromKevin, object: nil, queue: nil) { (notification) in
      self.configureConnectButton()
      self.configureToggleButton()
    }
    notificationCenter.addObserver(forName: Notification.Name.relayValueChanged, object: nil, queue: nil) { (notification) in
        self.configureToggleButton()
    }
  }
  
  func configureConnectButton() {
    DispatchQueue.main.async {
      switch self.kevin.kevinPeripheral?.state {
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
  
  func configureToggleButton() {
    DispatchQueue.main.async {
      switch self.kevin.kevinPeripheral?.state {
      case .connected?:
        self.toggleCameraButton.isEnabled = true
        if let relayValue = self.kevin.relayValue, relayValue {
          self.toggleCameraButton.setTitle("Turn OFF", for: .normal)
        }
        else {
          self.toggleCameraButton.setTitle("Turn ON", for: .normal)
        }

      case .connecting?, .disconnected?, .disconnecting?:
        self.toggleCameraButton.isEnabled = false
        self.toggleCameraButton.setTitle("N/A", for: .normal)
        
      default: ()
      }
    }
  }
}
