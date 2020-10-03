private class _TitledMatrixBase<Item, XLabel: Equatable, YLabel: Equatable> {
	var xLabels: [XLabel]
	var yLabels: [YLabel]
	var items: [Item?]

	init(xLabels: [XLabel], yLabels: [YLabel], items: [Item?]) {
		self.xLabels = xLabels
		self.yLabels = yLabels
		self.items = items
	}

	convenience init() {
		self.init(xLabels: [], yLabels: [], items: [])
	}

	func clone() -> _TitledMatrixBase<Item, XLabel, YLabel> {
		_TitledMatrixBase(xLabels: xLabels, yLabels: yLabels, items: items)
	}
}

public struct TitledMatrix<Item, XLabel: Equatable, YLabel: Equatable> {
	private typealias Base = _TitledMatrixBase<Item, XLabel, YLabel>

	private var base: Base

	private mutating func uniqueBase() -> Base {
		if !isKnownUniquelyReferenced(&base) {
			base = base.clone()
		}
		return base
	}
}

// MARK: - Public

public extension TitledMatrix {
	var xLabels: [XLabel] {
		get { base.xLabels }
		set { uniqueBase().xLabels = newValue }
	}
	var yLabels: [YLabel] {
		get { base.yLabels }
		set { uniqueBase().yLabels = newValue }
	}
	var items: [Item?] {
		get { base.items }
		set { uniqueBase().items = newValue }
	}

	init(_ items: [YLabel: [XLabel: Item]]) where XLabel: Hashable, YLabel: Hashable {
		self.base = .init()

		for (y, xiPair) in items {
			let yIdx = add(newYLabel: y)
			for (x, i) in xiPair {
				let xIdx = add(newXLabel: x)
				let iIdx = itemIndex(x: xIdx, y: yIdx)
				while iIdx >= base.items.count {
					base.items.append(nil)
				}
				base.items[iIdx] = i
			}
		}
	}

	subscript(x: XLabel, y: YLabel) -> Item? {
		get {
			guard
				let xIdx = xLabels.firstIndex(of: x),
				let yIdx = yLabels.firstIndex(of: y)
			else { return nil }
			let idx = (xLabels.count * yIdx) + xIdx

			return items[idx]
		}
		set {
			let xIdx = add(newXLabel: x)
			let yIdx = add(newYLabel: y)
			let itemIdx = itemIndex(x: xIdx, y: yIdx)
			items[itemIdx] = newValue
		}
	}

	@discardableResult
	mutating func add(newXLabel: XLabel) -> Int {
		if let idx = xLabels.firstIndex(of: newXLabel) { return idx }
		xLabels.append(newXLabel)
		let x = xLabels.endIndex - 1
		for y in yLabels.indices {
			let idx = y * (x + 1) + x
			if idx < items.count {
				items.insert(nil, at: idx)
			} else {
				items.append(nil)
			}
		}
		return x
	}

	@discardableResult
	mutating func add(newYLabel: YLabel) -> Int {
		if let idx = yLabels.firstIndex(of: newYLabel) { return idx }
		yLabels.append(newYLabel)
		items.append(contentsOf: Array(repeating: nil, count: xLabels.count))
		return yLabels.endIndex - 1
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
		private var itemIdx = 0
		private var xIdx = 0
		private var yIdx = 0

		init(_ matrix: TitledMatrix<Item, XLabel, YLabel>) {
			self.matrix = matrix
		}

		public mutating func next() -> TitledMatrix<Item, XLabel, YLabel>.Element? {
			guard
				xIdx < matrix.xLabels.count,
				yIdx < matrix.yLabels.count,
				itemIdx < matrix.items.count
			else { return nil }

			defer {
				itemIdx += 1
				xIdx += 1
				if xIdx >= matrix.xLabels.count {
					xIdx = 0
					yIdx += 1
				}
			}

			return Element(
				item: matrix.items[itemIdx],
				xLabel: matrix.xLabels[xIdx],
				yLabel: matrix.yLabels[yIdx])
		}
	}

	public __consuming func makeIterator() -> Iterator {
		Iterator(self)
	}
}

// MARK: - Collection

extension TitledMatrix: RandomAccessCollection {
	public struct Index: Comparable, Strideable {
		internal var itemIdx: Int

		internal init(_ itemIdx: Int) {
			self.itemIdx = itemIdx
		}

		public static func < (
			lhs: TitledMatrix<Item, XLabel, YLabel>.Index,
			rhs: TitledMatrix<Item, XLabel, YLabel>.Index
		) -> Bool {
			lhs.itemIdx < rhs.itemIdx
		}

		public func distance(to other: TitledMatrix<Item, XLabel, YLabel>.Index) -> Int {
			other.itemIdx - self.itemIdx
		}

		public func advanced(by n: Int) -> TitledMatrix<Item, XLabel, YLabel>.Index {
			Index(itemIdx + n)
		}
	}

	public typealias Indices = CountableRange<Index>

	public var startIndex: Index {
		Index(items.startIndex)
	}

	public var endIndex: Index {
		Index(items.endIndex)
	}

	public subscript(_ position: Index) -> Element {
		get {
			let (yIdx, xIdx) = position.itemIdx.quotientAndRemainder(dividingBy: xLabels.count)
			return Element(
				item: items[position.itemIdx],
				xLabel: xLabels[xIdx],
				yLabel: yLabels[yIdx])
		}
	}

	public func index(before i: Index) -> Index {
		Index(items.index(before: i.itemIdx))
	}

	public func index(after i: Index) -> Index {
		Index(items.index(after: i.itemIdx))
	}

	public func distance(from start: Index, to end: Index) -> Int {
		end.itemIdx - start.itemIdx
	}
}

// MARK: - Literals

extension TitledMatrix: ExpressibleByDictionaryLiteral {
	public init(dictionaryLiteral elements: ((x: XLabel, y: YLabel), Item)...) {
		base = .init()

		for ((x, y), item) in elements {
			let xIdx = add(newXLabel: x)
			let yIdx = add(newYLabel: y)
			let iIdx = itemIndex(x: xIdx, y: yIdx)
			while iIdx >= items.count {
				items.append(nil)
			}
			items[iIdx] = item
		}
	}
}

// MARK: - SubType Extensions

extension TitledMatrix.Element: Equatable where Item: Equatable {}

// MARK: - Private Helpers

private extension TitledMatrix {
	func itemIndex(x: Int, y: Int) -> Int {
		y * xLabels.count + x
	}
}

