//
//  ViewController.swift
//  BicycleTracker
//
//  Created by Alexander Kolov on 3/10/15.
//  Copyright (c) 2015 Alexander Kolov. All rights reserved.
//

import CoreMotion
import HealthManager
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var pulseLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
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
      self.speedLabel.text = "\(HealthManager.sharedInstance.heartRate)"
      self.pulseLabel.text = "\(HealthManager.sharedInstance.heartRate)"
      self.distanceLabel.text = "\(HealthManager.sharedInstance.distance)"

      if let error = HealthManager.sharedInstance.error {
        self.debugLabel.text = "\(error)"
      }
      else if let update = HealthManager.sharedInstance.updateDate {
        self.debugLabel.text = "Last update: \(update)"
      }
    }

    let distanceAvailable = CMPedometer.isDistanceAvailable() ? "Distance available" : "Distance not available"
    debugLabel.text = "\(distanceAvailable)"
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
