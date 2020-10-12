//
//  File.swift
//  
//
//  Created by Jon Bash on 2020-10-09.
//

import Foundation


public extension Date {
	func next(inCalendar cal: Calendar = .current) -> Date {
		cal.date(byAdding: .day, value: 1, to: self)!
	}

	func interval(
		of component: Calendar.Component = .day,
		inCalendar cal: Calendar = .current
	) -> DateInterval? {
		cal.dateInterval(of: component, for: self)
	}

	static func - (lhs: Date, rhs: Date) -> TimeInterval {
		rhs.distance(to: lhs)
	}
}


public extension Calendar.Component {
	var timeInterval: TimeInterval? {
		switch self {
		case .day:
			return 86_400
		case .hour:
			return 3_600
		case .minute:
			return 60
		case .second:
			return 1
		case .weekOfMonth:
			return 604_800
		case .weekOfYear:
			return 604_800
		case .nanosecond:
			return 0.000000001
		default:
			return nil
		}
	}
}
