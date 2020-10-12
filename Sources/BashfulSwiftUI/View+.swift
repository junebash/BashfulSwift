import SwiftUI


public extension View {
	/// Masks this view using the alpha channel of the given view. Inverse of regular mask.
	func inverseMask<Mask: View>(_ mask: Mask) -> some View {
		self.mask(
			mask.foregroundColor(.black)
				.background(Color.white)
				.compositingGroup()
				.luminanceToAlpha()
		)
	}

	/// Reads the provided key path value from a `GeometryReader`'s proxy applied to the view's background
	/// and applies it to the provided preference key, performing the provided closure when the preference changes.
	/// Useful for reading size values, writing them to a size binding, and aligning several views according to this value.
	func readingGeometry<K: PreferenceKey>(
		key: K.Type,
		valuePath: KeyPath<GeometryProxy, K.Value>,
		onChange: @escaping (K.Value) -> Void
	) -> some View where K.Value: Equatable {
		self.background(GeometryReader { proxy in
			Color.clear
				.preference(key: K.self,
								value: proxy[keyPath: valuePath])
		}).onPreferenceChange(K.self, perform: { onChange($0) })
	}

	/// Reads the provided key path value from a `GeometryReader`'s proxy applied to the view's background
	/// and applies it to the provided preference key, performing the provided closure when the preference changes.
	/// Useful for reading size values, writing them to a size binding, and aligning several views according to this value.
	func readingGeometry<K: PreferenceKey, V>(
		key: K.Type,
		valuePath: KeyPath<GeometryProxy, V>,
		onChange: @escaping (K.Value) -> Void
	) -> some View where K.Value == V?, V: Equatable {
		self.background(GeometryReader { proxy in
			Color.clear
				.preference(key: K.self,
								value: proxy[keyPath: valuePath])
		}).onPreferenceChange(K.self, perform: { onChange($0) })
	}
}
