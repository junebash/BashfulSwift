//
//  File.swift
//  
//
//  Created by Jon Bash on 2020-10-09.
//

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(macOS)
import Cocoa
#endif

public protocol FiniteNumeric: Numeric {
	static var min: Self { get }
	static var max: Self { get }
}

extension Int8: FiniteNumeric {}
extension Int16: FiniteNumeric {}
extension Int32: FiniteNumeric {}
extension Int64: FiniteNumeric {}
extension Int: FiniteNumeric {}
extension UInt8: FiniteNumeric {}
extension UInt16: FiniteNumeric {}
extension UInt32: FiniteNumeric {}
extension UInt64: FiniteNumeric {}
extension UInt: FiniteNumeric {}

extension BinaryFloatingPoint where Self: FiniteNumeric {
	public static var min: Self { -.greatestFiniteMagnitude }
	public static var max: Self { .greatestFiniteMagnitude }
}
extension Double: FiniteNumeric {}
extension Float: FiniteNumeric {}
extension CGFloat: FiniteNumeric {
	public static var min: Self { -.greatestFiniteMagnitude }
	public static var max: Self { .greatestFiniteMagnitude }
}


public extension ClosedRange {
	static func atLeast<N: FiniteNumeric>(_ min: N) -> ClosedRange<N> {
		min...N.max
	}

	static func atMost<N: FiniteNumeric>(_ max: N) -> ClosedRange<N> {
		N.min...max
	}
}


public extension TimeInterval {
	static func minutes(_ min: Int) -> Self {
		TimeInterval(min) * 60
	}

	static func hours(_ hrs: Int) -> Self {
		TimeInterval(hrs) * 3600
	}

	static func days(_ dys: Int) -> Self {
		TimeInterval(dys) * 86_400
	}

	static func weeks(_ wks: Int) -> Self {
		TimeInterval(wks) * 604_800
	}
}


public extension DateInterval {
	static func ~= (period: DateInterval, date: Date) -> Bool {
		period.contains(date)
	}
}
