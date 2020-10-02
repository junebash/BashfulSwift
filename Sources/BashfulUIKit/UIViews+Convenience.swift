#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit


extension UIStackView {
	/// Initializes a stack view with the given parameters and arranged subviews.
	///
	/// - Parameters:
	///   - axis: Default `.vertical`
	///   - alignment: Default `.fill`
	///   - distribution: Default `.fill`
	///   - spacing: Default `8`
	///   - arrangedSubviews: Default `[]`
	convenience init(
		axis: NSLayoutConstraint.Axis = .vertical,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 8,
		arrangedSubviews: [UIView] = []
	) {
		self.init()
		self.axis = axis
		self.alignment = alignment
		self.distribution = distribution
		self.spacing = spacing
		arrangedSubviews.forEach(addArrangedSubview(_:))
	}
}
#endif
