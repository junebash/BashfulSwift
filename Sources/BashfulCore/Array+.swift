public extension Array where Element: Equatable {
	mutating func firstIndex(appendingIfNil element: Element) -> Int {
		firstIndex(of: element) ?? {
			append(element)
			return endIndex - 1
		}()
	}
}
