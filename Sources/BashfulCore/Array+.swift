public extension Array where Element: Equatable {
	mutating func firstIndex(appendingIfNil element: Element) -> Int {
		firstIndex(of: element) ?? {
			append(element)
			return endIndex - 1
		}()
	}
}


public func ~= <S: Sequence>(sequence: S, element: S.Element) -> Bool where S.Element: Equatable {
	sequence.contains(element)
}
