/// Indicates that the optional value from which this was thrown was nil.
public struct UnwrapError<Wrapped>: Error, CustomStringConvertible {
	public var description: String {
		"Expected \(Wrapped.self) but got nil"
	}
}

public extension Optional {
	/// If non-nil, wrapped value is returned; else, an error is thrown (a custom error if provided, otherwise an instance of `UnwrapError`).
	func throwUnwrap(else error: Error? = nil) throws -> Wrapped {
		guard let unwrapped = self else { throw error ?? UnwrapError<Wrapped>() }
		return unwrapped
	}
}

public extension Sequence {
	/// On a collection of `Optional<T>`, the provided closure is applied to each non-nil value, after which the non-nil values are returned in a new array.
	///
	/// You may think of it as equivalent to:
	/// ```
	/// arrayOfOptionals.compactMap {
	///    $0.map(providedTransform)
	/// }
	/// ```
	func compactMapNonNil<T, R>(
		_ transform: @escaping (T) throws -> R
	) rethrows -> [R] where Element == T? {
		try self.reduce(into: []) { result, optV in
			if let v = optV {
				try result.append(transform(v))
			}
		}
	}
}
