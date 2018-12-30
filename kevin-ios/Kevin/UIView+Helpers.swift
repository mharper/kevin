//
//  UIView+Helpers.swift
//  Beaconland
//
//  Created by Michael Harper on 7/16/18.
//  Copyright © 2018 RadiusNetworks, Inc. All rights reserved.
//

import UIKit

extension UIView {
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
}
