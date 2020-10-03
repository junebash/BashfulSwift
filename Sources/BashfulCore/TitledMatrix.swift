//
//  File.swift
//  
//
//  Created by Jon Bash on 2020-10-03.
//


public struct TitledMatrix<Item, XLabel: Hashable, YLabel: Hashable> {
	public private(set) var xLabels: [XLabel]
	public private(set) var yLabels: [YLabel]
	internal var items: [Item?]
}

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

extension TitledMatrix: RandomAccessCollection {
	public struct Index: Comparable, Strideable {
		internal var itemIdx: Int

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
			Index(itemIdx: self.itemIdx + n)
		}
	}

	public typealias Indices = CountableRange<Index>

	public var startIndex: Index {
		Index(itemIdx: items.startIndex)
	}

	public var endIndex: Index {
		Index(itemIdx: items.endIndex)
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
		Index(itemIdx: items.index(before: i.itemIdx))
	}

	public func index(after i: Index) -> Index {
		Index(itemIdx: items.index(after: i.itemIdx))
	}

	public func distance(from start: Index, to end: Index) -> Int {
		end.itemIdx - start.itemIdx
	}
}
