

/// Configure the provided item with the provided closure, and then return the configured item.
/// - Parameters:
///   - item: Any value to be confifured
///   - f: A closure that takes in an `inout` copy of the provided `item` and performs some transformation on it.
/// - Returns: The configured item.
@discardableResult
public func configure<T>(_ item: T, with f: (inout T) -> Void) -> T {
	var copy = item
	f(&copy)
	return copy
}
