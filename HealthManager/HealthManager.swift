//
//  HealthManager.swift
//  BicycleTracker
//
//  Created by Alexander Kolov on 3/10/15.
//  Copyright (c) 2015 Alexander Kolov. All rights reserved.
//

import CoreLocation
import CoreMotion
import Foundation
import HealthKit

public let HealthManagerDidUpdateNotification = "HealthManagerDidUpdateNotification"

public class HealthManager: NSObject, CLLocationManagerDelegate {

  public class var sharedInstance: HealthManager {
    struct Static {
      static let instance: HealthManager = HealthManager()
    }
    return Static.instance
  }

  private var startDate: NSDate!
  private var stopDate: NSDate?

  private var _updateDate: NSDate?
  public var updateDate: NSDate? {
    return _updateDate
  }

  public var active: Bool {
    return startDate != nil && stopDate == nil
  }

  public var error: NSError?

  private let pedometer = CMPedometer()
  public var motionSpeed: HKQuantity = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: 0)
  public var motionDistance: HKQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0)

  public var heartRate: HKQuantity = HKQuantity(unit: HKUnit.heartBeatsPerMinuteUnit(), doubleValue: 0)

  private lazy var locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.distanceFilter = kCLDistanceFilterNone
    manager.delegate = self
    return manager
  }()

  private var lastLocation: CLLocation?
  public var locationSpeed: HKQuantity = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: 0)
  public var locationDistance: HKQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0)

  public func start() {
    if startDate != nil {
      return
    }

    startDate = NSDate()

    NSNotificationCenter.defaultCenter().postNotificationName(HealthManagerDidUpdateNotification, object: nil)

    locationManager.startUpdatingLocation()

    pedometer.startPedometerUpdatesFromDate(startDate) { data, error in
      self._updateDate = NSDate()
      if data == nil {
        self.error = error
        NSNotificationCenter.defaultCenter().postNotificationName(HealthManagerDidUpdateNotification, object: nil)
      }
      else {
        self.motionDistance = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: data.distance.doubleValue ?? 0)
        let speedValue = data.distance.doubleValue / (self._updateDate!.timeIntervalSinceDate(self.startDate))
        self.motionSpeed = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: speedValue)
        self.probeHeartRate(self._updateDate!)
        NSNotificationCenter.defaultCenter().postNotificationName(HealthManagerDidUpdateNotification, object: nil)
      }
    }
  }

  public func stop() {
    if startDate == nil {
      return
    }

    stopDate = NSDate()
    pedometer.stopPedometerUpdates()
    locationManager.stopUpdatingLocation()

    saveWorkout()
    reset()

    startDate = nil
    stopDate = nil
    _updateDate = nil
  }

  public func probeHeartRate(date: NSDate) {
    let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
    let predicate = HKQuery.predicateForSamplesWithStartDate(date, endDate: date, options: .None)
    let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: nil) { query, results, error in
      if let sample = results.first as? HKQuantitySample {
        self.heartRate = sample.quantity
      }
    }
  }

  public func probeDistance(date: NSDate) {
    let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceCycling)
    let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: date, options: .StrictStartDate)
    let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: nil) { query, results, error in
      if let sample = results.first as? HKQuantitySample {
        self.motionDistance = sample.quantity
      }
    }
  }

  public func saveWorkout() {

  }

  public func reset() {
    motionSpeed = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: 0)
    motionDistance = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0)
    locationSpeed = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: 0)
    locationDistance = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0)
    heartRate = HKQuantity(unit: HKUnit.heartBeatsPerMinuteUnit(), doubleValue: 0)
  }

  // MARK: CLLocationManagerDelegate

  public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if let location = locations.last as? CLLocation {
      locationSpeed = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: location.speed ?? 0)

      if let lastLocation = lastLocation {
        locationDistance = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: location.distanceFromLocation(lastLocation))
      }

      lastLocation = location
    }
  }

}
