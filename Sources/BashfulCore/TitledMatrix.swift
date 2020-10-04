public struct TitledMatrix<Item, XLabel: Equatable, YLabel: Equatable> {
	private var base: _Base
}

// MARK: - Base

private extension TitledMatrix {
	private class _Base {
		var xLabels: [_Label<XLabel>]
		var yLabels: [_Label<YLabel>]
		var items: [Index: Item]

		init(xLabels: [_Label<XLabel>], yLabels: [_Label<YLabel>], items: [Index: Item]) {
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

	private class _Label<V>: Hashable {
		private var _value: V
		
		var value: V { _value }

		init(_ value: V) {
			self._value = value
		}

		static func == (
			lhs: TitledMatrix<Item, XLabel, YLabel>._Label<V>,
			rhs: TitledMatrix<Item, XLabel, YLabel>._Label<V>
		) -> Bool {
			lhs === rhs
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(ObjectIdentifier(self))
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
	var xLabels: [XLabel] { _xLabels.map(\.value) }
	var yLabels: [YLabel] { _yLabels.map(\.value) }
	var items: [Item] { base.items.values.map { $0 } }

	init(xLabels: [XLabel], yLabels: [YLabel], items: [Index: Item]) {
		self.init(
			base: .init(
				xLabels: xLabels.map(_Label.init),
				yLabels: yLabels.map(_Label.init),
				items: items))
	}

	subscript(_ x: XLabel, _ y: YLabel) -> Item? {
		get {
			guard
				let xIdx = _xLabels.firstIndex(of: _Label(x)),
				let yIdx = _yLabels.firstIndex(of: _Label(y))
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
		uniqueBase().xLabels.firstIndex(appendingIfNil: .init(newXLabel))
	}

	@discardableResult
	mutating func add(newYLabel: YLabel) -> Int {
		uniqueBase().yLabels.firstIndex(appendingIfNil: .init(newYLabel))
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
				xIdx < matrix._xLabels.count,
				yIdx < matrix._yLabels.count
			else { return nil }

			defer {
				xIdx += 1
				if xIdx >= matrix._xLabels.count {
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

extension TitledMatrix: RandomAccessCollection {
	public struct Index: Comparable, Strideable, Hashable {
		internal var x: Int
		internal var y: Int
		internal var xCount: Int

		internal init(x: Int, y: Int, xCount: Int) {
			self.x = x
			self.y = y
			self.xCount = xCount
		}

		public init(x: Int, y: Int, matrix: TitledMatrix) {
			self.init(x: x, y: y, xCount: matrix._xLabels.count)
		}

		public static func < (lhs: Index, rhs: Index) -> Bool {
			lhs.x > rhs.x && lhs.y > rhs.y
		}

		public func distance(to other: Index) -> Int {
			let dx = other.x - self.x
			let dy = other.y - self.y
			return dy * xCount + dx
		}

		public func advanced(by n: Int) -> Index {
			let (newY, newX) = ((y * xCount + x) + n)
				.quotientAndRemainder(dividingBy: xCount)

			return Index(x: newX, y: newY, xCount: xCount)
		}

		public func hash(into hasher: inout Hasher) {
			hasher.combine(x)
			hasher.combine(y)
		}
	}

	public typealias Indices = CountableRange<Index>

	public var startIndex: Index {
		Index(x: 0, y: 0, xCount: _xLabels.count)
	}

	public var endIndex: Index {
		Index(x: 0, y: base.yLabels.endIndex, matrix: self)
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
	private var _xLabels: [_Label<XLabel>] {
		get { base.xLabels }
		set { uniqueBase().xLabels = newValue }
	}
	private var _yLabels: [_Label<YLabel>] {
		get { base.yLabels }
		set { uniqueBase().yLabels = newValue }
	}
}

