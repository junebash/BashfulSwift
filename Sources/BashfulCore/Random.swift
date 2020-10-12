import Foundation


private var _rng: RandomNumberGenerator = SystemRandomNumberGenerator()


public protocol Randomizable {
	static func random() -> Self
	static func random(using generator: inout RandomNumberGenerator) -> Self
}

public extension Randomizable where Self: CaseIterable, Self.AllCases == Array<Self> {
	static func random(using generator: inout RandomNumberGenerator) -> Self {
		allCases[Int(generator.next(upperBound: UInt64(allCases.count)))]
	}

	static func random() -> Self {
		random(using: &_rng)
	}
}


public extension Date {
	static func random(in dateInterval: DateInterval) -> Date {
		var rng = SystemRandomNumberGenerator()
		return random(in: dateInterval, using: &rng)
	}

	static func random<Generator: RandomNumberGenerator>(
		in dateInterval: DateInterval,
		using gen: inout Generator
	) -> Date {
		let timeFromStart = Double.random(in: 0...dateInterval.duration, using: &gen)
		return dateInterval.start + timeFromStart
	}
}
