//
//  ViewController.swift
//  KevinCam
//
//  Created by Michael Harper on 12/28/18.
//  Copyright © 2018 Michael Harper. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var connectDisconnectButton: UIButton!
  @IBOutlet weak var toggleRelayButton: UIButton!
  
  var relayOn = false
  
  let kevin = Kevin.shared

  override func viewDidLoad() {
    super.viewDidLoad()
    registerForNotifications()
    configureConnectButton()
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
  
  @IBAction func toggleRelayAction(_ sender: Any) {
    relayOn = !relayOn
    kevin.writeRelayCharacteristic(relayOn)
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
        self.toggleRelayButton.isEnabled = true
        if let relayValue = self.kevin.relayValue, relayValue {
          self.toggleRelayButton.setTitle("Turn OFF", for: .normal)
        }
        else {
          self.toggleRelayButton.setTitle("Turn ON", for: .normal)
        }
        
      case .connecting?, .disconnected?, .disconnecting?:
        self.toggleRelayButton.isEnabled = false
        self.toggleRelayButton.setTitle("N/A", for: .normal)
        
      default: ()
      }
    }
  }
}

