//
//  ViewController.swift
//  BicycleTracker
//
//  Created by Alexander Kolov on 3/10/15.
//  Copyright (c) 2015 Alexander Kolov. All rights reserved.
//

import CoreLocation
import CoreMotion
import HealthManager
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var motionSpeedLabel: UILabel!
  @IBOutlet weak var motionDistanceLabel: UILabel!
  @IBOutlet weak var locationSpeedLabel: UILabel!
  @IBOutlet weak var locationDistanceLabel: UILabel!
  @IBOutlet weak var heartRateLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var debugLabel: UILabel!

  private var observer: AnyObject?

  deinit {
    if let observer: AnyObject = observer {
      NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    startButton.setTitle(NSLocalizedString("Start", comment: "Start button title"), forState: .Normal)
    startButton.setTitle(NSLocalizedString("Stop", comment: "Stop button title"), forState: .Selected)

    observer = NSNotificationCenter.defaultCenter().addObserverForName(HealthManagerDidUpdateNotification, object: nil, queue: NSOperationQueue.mainQueue()) { note in
      self.motionSpeedLabel.text = "Motion speed: \(HealthManager.sharedInstance.motionSpeed)"
      self.motionDistanceLabel.text = "Motion distance: \(HealthManager.sharedInstance.motionDistance)"

      self.locationSpeedLabel.text = "Location speed: \(HealthManager.sharedInstance.locationSpeed)"
      self.locationDistanceLabel.text = "Location distance: \(HealthManager.sharedInstance.locationDistance)"

      self.heartRateLabel.text = "\(HealthManager.sharedInstance.heartRate)"

      if let error = HealthManager.sharedInstance.error {
        self.debugLabel.text = "\(error)"
      }
      else {
        let motionUpdate = HealthManager.sharedInstance.motionUpdateDate
        let locationUpdate = HealthManager.sharedInstance.locationUpdateDate
        self.debugLabel.text = "Last motion update: - \(motionUpdate)\nLast location update: - \(locationUpdate)"
      }
    }

    let distanceAvailable = CMPedometer.isDistanceAvailable() ? "Distance information available" : "Distance information not available"
    let locationAvailable = CLLocationManager.locationServicesEnabled() ? "Location services are enabled" : "Location services are disabled"
    debugLabel.text = "\(distanceAvailable), \(locationAvailable)"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK -

  @IBAction func didTapStartButton(sender: UIButton) {
    if HealthManager.sharedInstance.active {
      HealthManager.sharedInstance.stop()
      startButton.selected = false
    }
    else {
      HealthManager.sharedInstance.start()
      startButton.selected = true
    }
  }

}
