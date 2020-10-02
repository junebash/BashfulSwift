/// Indicates that the optional value from which this was thrown was nil.
public struct UnwrapError<Wrapped>: Error, CustomStringConvertible {
	public var description: String {
		"Expected \(Wrapped.self) but got nil"
	}
}


/// Alternatively, `?<-`?
/// (`let x = self.point?.x ?<- CGPoint.zero` vs.
/// `let x = self.point?.x ?=? CGPoint.zero`)
///
/// See `Optional.orSettingIfNil` to see use in practice.
infix operator ?=?


public extension Optional {
	/// If non-nil, wrapped value is returned; else, an error is thrown (a custom error if provided, otherwise an instance of `UnwrapError`).
	func throwUnwrap(else error: Error? = nil) throws -> Wrapped {
		guard let unwrapped = self else { throw error ?? UnwrapError<Wrapped>() }
		return unwrapped
	}

	/// If nil, sets wrapped value to the new value and then returns it. If non-nil, ignores the new value
	/// and simply returns the wrapped value.
	///
	/// Similar to the nil-coalescing operator (`??`), but additionally sets the wrapped value if non-nil.
	mutating func orSettingIfNil(_ newValueIfNil: Wrapped) -> Wrapped {
		if self == nil { self = newValueIfNil }
		return self!
	}

	/// If nil, sets wrapped value to the new value and then returns it. If non-nil, ignores the new value
	/// and simply returns the wrapped value.
	///
	/// Similar to the nil-coalescing operator (`??`), but additionally sets the left-hand value if non-nil.
	static func ?=? (lhs: inout Wrapped?, rhs: Wrapped) -> Wrapped {
		lhs.orSettingIfNil(rhs)
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
