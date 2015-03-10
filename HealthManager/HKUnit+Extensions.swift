//
//  HKUnit+Extensions.swift
//  BicycleTracker
//
//  Created by Alexander Kolov on 3/10/15.
//  Copyright (c) 2015 Alexander Kolov. All rights reserved.
//

import Foundation
import HealthKit

public extension HKUnit {

  public class func heartBeatsPerMinuteUnit() -> HKUnit {
    return HKUnit.countUnit().unitDividedByUnit(HKUnit.minuteUnit())
  }

  public class func metersPerSecondUnit() -> HKUnit {
    return HKUnit.meterUnit().unitDividedByUnit(HKUnit.secondUnit())
  }

public class func kilometersPerSecondUnit() -> HKUnit {
  return HKUnit.meterUnitWithMetricPrefix(.Kilo).unitDividedByUnit(HKUnit.hourUnit())
}

}
