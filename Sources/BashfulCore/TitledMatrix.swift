public struct TitledMatrix<Item, XLabel: Hashable, YLabel: Hashable> {
	private var base: _Base
}

// MARK: - Base

private extension TitledMatrix {
	private class _Base {
		// TODO: Replace with OrderedSets
		var xLabels: [XLabel]
		var yLabels: [YLabel]
		var items: [Index: Item]

		init(xLabels: [XLabel], yLabels: [YLabel], items: [Index: Item]) {
			self.xLabels = xLabels
			self.yLabels = yLabels
			self.items = items
		}

		convenience init() {
			self.init(xLabels: [], yLabels: [], items: [:])
		}

		func clone() -> _Base {
			_Base(xLabels: xLabels, yLabels: yLabels, items: items)
		}
	}

	private class _Label<V: Hashable>: Hashable {
		var value: V

		init(_ value: V) {
			self.value = value
		}

		static func == (
			lhs: TitledMatrix<Item, XLabel, YLabel>._Label<V>,
			rhs: TitledMatrix<Item, XLabel, YLabel>._Label<V>
		) -> Bool {
			lhs.value == rhs.value
		}

		func hash(into hasher: inout Hasher) {
			value.hash(into: &hasher)
		}
	}

	private mutating func uniqueBase() -> _Base {
		if !isKnownUniquelyReferenced(&base) {
			base = base.clone()
		}
		return base
	}
}

// MARK: - Public

public extension TitledMatrix {
	var xLabels: [XLabel] { base.xLabels }
	var yLabels: [YLabel] { base.yLabels }
	var items: [Item] { base.items.values.map { $0 } }

	init<C: Collection>(xLabels: [XLabel], yLabels: [YLabel], elements: C) where C.Element == Element {
		self.base = .init()

		let xLookup = xLabels.enumerated().reduce(into: [XLabel: Int]()) { r, enmrt in
			r[enmrt.element] = enmrt.offset
		}
		let yLookup = yLabels.enumerated().reduce(into: [YLabel: Int]()) { r, enmrt in
			r[enmrt.element] = enmrt.offset
		}

		let items = elements.reduce(into: [Index: Item]()) { itemsByIndex, el in
			if let item = el.item {
				guard let x = xLookup[el.xLabel], let y = yLookup[el.yLabel] else {
					return
				}
				itemsByIndex[Index(x: x, y: y, matrix: self)] = item
			}
		}
		self.base.items = items
		self.base.xLabels = xLabels
	}

	subscript(_ x: XLabel, _ y: YLabel) -> Item? {
		get {
			guard
				let xIdx = xLabels.firstIndex(of: x),
				let yIdx = yLabels.firstIndex(of: y)
			else { return nil }
			return self[xIdx, yIdx]
		}
		set {
			let idx = Index(
				x: add(newXLabel: x),
				y: add(newYLabel: y),
				matrix: self)

			uniqueBase().items[idx] = newValue
		}
	}

	subscript(_ x: Int, _ y: Int) -> Item? {
		get {
			base.items[Index(x: x, y: y, matrix: self)]
		}
		set {
			uniqueBase().items[Index(x: x, y: y, matrix: self)] = newValue
		}
	}

	@discardableResult
	mutating func add(newXLabel: XLabel) -> Int {
		uniqueBase().xLabels.firstIndex(appendingIfNil: newXLabel)
	}

	@discardableResult
	mutating func add(newYLabel: YLabel) -> Int {
		uniqueBase().yLabels.firstIndex(appendingIfNil: newYLabel)
	}
}

// MARK: - Sequence

extension TitledMatrix: Sequence {
	public struct Element {
		public let item: Item?
		public let xLabel: XLabel
		public let yLabel: YLabel
	}

	public struct Iterator: IteratorProtocol {
		private let matrix: TitledMatrix<Item, XLabel, YLabel>
		private var xIdx = 0
		private var yIdx = 0

		init(_ matrix: TitledMatrix<Item, XLabel, YLabel>) {
			self.matrix = matrix
		}

		public mutating func next() -> TitledMatrix<Item, XLabel, YLabel>.Element? {
			guard
				xIdx < matrix.xLabels.count,
				yIdx < matrix.yLabels.count
			else { return nil }

			defer {
				xIdx += 1
				if xIdx >= matrix.xLabels.count {
					xIdx = 0
					yIdx += 1
				}
			}

			return Element(
				item: matrix.base.items[Index(x: xIdx, y: yIdx, matrix: matrix)],
				xLabel: matrix.xLabels[xIdx],
				yLabel: matrix.yLabels[yIdx])
		}
	}

	public func makeIterator() -> Iterator {
		Iterator(self)
	}
}

// MARK: - Collection

extension TitledMatrix: BidirectionalCollection {
	public struct Index: Comparable, Hashable {
		internal var x: Int
		internal var y: Int

		private weak var matrixBase: TitledMatrix._Base?

		internal var absoluteIndex: Int? {
			guard let base = matrixBase else { return nil }
			return base.xLabels.count * y + x
		}

		internal init(x: Int, y: Int, matrix: TitledMatrix) {
			self.x = x
			self.y = y
			self.matrixBase = matrix.base
		}

		public static func == (lhs: Index, rhs: Index) -> Bool {
			lhs.x == rhs.x
				&& lhs.y == rhs.y
				&& lhs.matrixBase === rhs.matrixBase
		}

		public static func < (lhs: Index, rhs: Index) -> Bool {
			guard let lai = lhs.absoluteIndex, let rai = rhs.absoluteIndex
			else { return false }

			return lhs.matrixBase === rhs.matrixBase && lai < rai
		}

		public func hash(into hasher: inout Hasher) {
			hasher.combine(x)
			hasher.combine(y)
		}
	}

	public var startIndex: Index {
		Index(x: 0, y: 0, matrix: self)
	}

	public var endIndex: Index {
		Index(x: 0, y: base.yLabels.endIndex, matrix: self)
	}

	public func index(before i: Index) -> Index {
		var newX = i.x - 1
		var newY = i.y
		if newX < 0 {
			newX = base.xLabels.count - 1
			newY -= 1
		}
		return Index(x: newX, y: newY, matrix: self)
	}

	public func index(after i: Index) -> Index {
		var newX = i.x + 1
		var newY = i.y
		if newX >= base.xLabels.count {
			newX = 0
			newY += 1
		}
		return Index(x: newX, y: newY, matrix: self)
	}

	public func distance(from start: Index, to end: Index) -> Int {
		(end.absoluteIndex ?? 0) - (start.absoluteIndex ?? 0)
	}

	public func index(_ i: Index, offsetBy distance: Int) -> Index {
		var newX = i.x + distance
		var newY = i.y
		while newX < 0 {
			newX += xLabels.count
			newY -= 1
		}
		while newX >= xLabels.count {
			newX -= xLabels.count
			newY += 1
		}
		return Index(x: newX, y: newY, matrix: self)
	}

	public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
		guard
			let absI = i.absoluteIndex,
			let absLimit = limit.absoluteIndex,
			absI + distance < absLimit
		else { return nil }
		return index(i, offsetBy: distance)
	}

	public subscript(_ position: Index) -> Element {
		get {
			Element(
				item: base.items[position],
				xLabel: xLabels[position.x],
				yLabel: yLabels[position.y])
		}
	}
}

// MARK: - SubType Extensions

extension TitledMatrix.Element: Equatable where Item: Equatable {}

// MARK: - Private Helpers

private extension TitledMatrix {

}

