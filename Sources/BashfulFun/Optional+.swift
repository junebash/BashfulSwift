public struct UnwrapError<Wrapped>: Error, CustomStringConvertible {
	public var description: String {
		"Expected \(Wrapped.self) but got nil"
	}
}

public extension Optional {
	func throwUnwrap(else error: Error? = nil) throws -> Wrapped {
		guard let unwrapped = self else { throw error ?? UnwrapError<Wrapped>() }
		return unwrapped
	}
}
