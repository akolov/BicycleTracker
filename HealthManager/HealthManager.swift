//
//  HealthManager.swift
//  BicycleTracker
//
//  Created by Alexander Kolov on 3/10/15.
//  Copyright (c) 2015 Alexander Kolov. All rights reserved.
//

import CoreMotion
import Foundation
import HealthKit

public let HealthManagerDidUpdateNotification = "HealthManagerDidUpdateNotification"

public class HealthManager {

  public class var sharedInstance: HealthManager {
    struct Static {
      static let instance: HealthManager = HealthManager()
    }
    return Static.instance
  }

  private var startDate: NSDate!
  private var stopDate: NSDate?
  public var active: Bool {
    return stopDate == nil
  }

  public var speed: HKQuantity = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: 0)
  public var distance: HKQuantity = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0)
  public var heartRate: HKQuantity = HKQuantity(unit: HKUnit.heartBeatsPerMinuteUnit(), doubleValue: 0)

  private let pedometer = CMPedometer()

  public func start() {
    startDate = NSDate()
    pedometer.startPedometerUpdatesFromDate(startDate) { data, error in
      let now = NSDate()
      if data == nil {
        println("ERROR: \(error)")
      }
      else {
        self.distance = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: data.distance.doubleValue ?? 0)
        let speedValue = self.distance.doubleValueForUnit(HKUnit.meterUnit()) / (now.timeIntervalSinceDate(self.startDate))
        self.speed = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: speedValue)
        self.probeHeartRate(now)
        NSNotificationCenter.defaultCenter().postNotificationName(HealthManagerDidUpdateNotification, object: nil)
      }
    }
  }

  public func stop() {
    stopDate = NSDate()
    pedometer.stopPedometerUpdates()
    saveWorkout()
    reset()
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
        self.distance = sample.quantity
      }
    }
  }

  public func saveWorkout() {

  }

  public func reset() {
    speed = HKQuantity(unit: HKUnit.metersPerSecondUnit(), doubleValue: 0)
    distance = HKQuantity(unit: HKUnit.meterUnit(), doubleValue: 0)
    heartRate = HKQuantity(unit: HKUnit.heartBeatsPerMinuteUnit(), doubleValue: 0)
  }

}
