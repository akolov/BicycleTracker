//
//  InterfaceController.swift
//  BicycleTracker WatchKit Extension
//
//  Created by Alexander Kolov on 3/10/15.
//  Copyright (c) 2015 Alexander Kolov. All rights reserved.
//

import Foundation
import HealthManager
import WatchKit

class GaugesInterfaceController: WKInterfaceController {

  @IBOutlet weak var speedLabel: WKInterfaceLabel!
  @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
  @IBOutlet weak var distanceLabel: WKInterfaceLabel!
  @IBOutlet weak var stopButton: WKInterfaceButton!

  private var observer: AnyObject?

  deinit {
    if let observer: AnyObject = observer {
      NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
  }

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    observer = NSNotificationCenter.defaultCenter().addObserverForName(HealthManagerDidUpdateNotification, object: nil, queue: NSOperationQueue.mainQueue()) { note in
      self.speedLabel.setText("\(HealthManager.sharedInstance.motionSpeed)")
      self.heartRateLabel.setText("\(HealthManager.sharedInstance.heartRate)")
      self.distanceLabel.setText("\(HealthManager.sharedInstance.motionDistance)")
    }
  }

  override func willActivate() {
    super.willActivate()
    HealthManager.sharedInstance.start()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

  @IBAction func didTapStopButton() {
    HealthManager.sharedInstance.stop()
    popToRootController()
  }

}
