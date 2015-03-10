//
//  ViewController.swift
//  BicycleTracker
//
//  Created by Alexander Kolov on 3/10/15.
//  Copyright (c) 2015 Alexander Kolov. All rights reserved.
//

import HealthManager
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var speedLabel: UILabel!
  @IBOutlet weak var pulseLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!

  private var observer: AnyObject?

  deinit {
    if let observer: AnyObject = observer {
      NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    startButton.setTitle(NSLocalizedString("Start", comment: "Start button title"), forState: .Normal)
    startButton.setTitle(NSLocalizedString("Stop", comment: "Stop button title"), forState: .Selected)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    observer = NSNotificationCenter.defaultCenter().addObserverForName(HealthManagerDidUpdateNotification, object: nil, queue: NSOperationQueue.mainQueue()) { note in
      self.speedLabel.text = "\(HealthManager.sharedInstance.heartRate)"
      self.pulseLabel.text = "\(HealthManager.sharedInstance.heartRate)"
      self.distanceLabel.text = "\(HealthManager.sharedInstance.distance)"
    }
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
