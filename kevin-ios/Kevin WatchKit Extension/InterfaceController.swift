//
//  InterfaceController.swift
//  Kevin WatchKit Extension
//
//  Created by Michael Harper on 12/23/18.
//  Copyright © 2018 Michael Harper. All rights reserved.
//

import WatchKit
import Foundation
import CoreBluetooth

class InterfaceController: WKInterfaceController {

  @IBOutlet weak var toggleRelayButton: WKInterfaceButton!
  @IBOutlet weak var connectDisconnectButton: WKInterfaceButton!
  
  var relayOn = false
  
  let kevin = Kevin.shared

  override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    registerForNotifications()
    configureConnectButton()
  }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

  @IBAction func connectDisconnectAction() {
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
  
  @IBAction func toggleRelayAction() {
    if let newRelayValue = kevin.relayValue?.toggled() {
      kevin.writeRelayCharacteristic(newRelayValue)
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
        self.connectDisconnectButton.setTitle("Disconnect")
//        self.connectDisconnectButton.setTitleColor(UIColor.white, for: .normal)
//        self.connectDisconnectButton.backgroundColor = UIColor.blue
        
      case .disconnected?, .disconnecting?:
        self.connectDisconnectButton.setTitle("Connect")
//        self.connectDisconnectButton.setTitleColor(UIColor.blue, for: .normal)
//        self.connectDisconnectButton.backgroundColor = UIColor.white
        
      default: ()
      }
    }
  }
  
  func configureToggleButton() {
    DispatchQueue.main.async {
      switch self.kevin.kevinPeripheral?.state {
      case .connected?:
        self.toggleRelayButton.setEnabled(true)
        if let relayValue = self.kevin.relayValue, relayValue == .closed {
          self.toggleRelayButton.setTitle("Turn OFF")
        }
        else {
          self.toggleRelayButton.setTitle("Turn ON")
        }
        
      case .connecting?, .disconnected?, .disconnecting?:
        self.toggleRelayButton.setEnabled(false)
        self.toggleRelayButton.setTitle("N/A")
        
      default: ()
      }
    }
  }
}
