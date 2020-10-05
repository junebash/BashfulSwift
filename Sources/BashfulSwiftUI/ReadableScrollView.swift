import SwiftUI


public struct ReadableScrollView<Content: View>: View {
	let axes: Axis.Set
	let showIndicators: Bool
	let content: Content

	@Binding var offset: CGSize

	public init(
		_ axes: Axis.Set = .vertical,
		showIndicators: Bool = true,
		offset: Binding<CGSize>,
		@ViewBuilder content: () -> Content
	) {
		self.axes = axes
		self.showIndicators = showIndicators
		self._offset = offset
		self.content = content()
	}

	public var body: some View {
		GeometryReader { outerProxy in
			ScrollView(axes, showsIndicators: showIndicators) {
				content.background(GeometryReader { innerProxy in
					Color.clear.preference(
						key: OffsetKey.self,
						value: [calculateContentOffset(
							fromOuterProxy: outerProxy,
							innerProxy: innerProxy)
						]
					)
				})
			}.onPreferenceChange(OffsetKey.self) { offsets in
				self.offset = offsets.first ?? .zero
			}
		}
	}

	private func calculateContentOffset(
		fromOuterProxy outerProxy: GeometryProxy,
		innerProxy: GeometryProxy
	) -> CGSize {
		var size = CGSize.zero
		if axes.contains(.vertical) {
			size.height =
				outerProxy.frame(in: .global).minY
				- innerProxy.frame(in: .global).minY
		}
		if axes.contains(.horizontal) {
			size.width =
				outerProxy.frame(in: .global).minX
				- innerProxy.frame(in: .global).minX
		}
		return size
	}
}


private struct OffsetKey: PreferenceKey {
	static var defaultValue: [CGSize] = [.zero]

	static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
		value.append(contentsOf: nextValue())
	}
}
