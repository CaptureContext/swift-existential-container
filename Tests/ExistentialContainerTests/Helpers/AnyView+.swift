#if canImport(SwiftUI)

import SwiftUI
@_spi(Internals) import ExistentialContainer

private protocol AnyViewConforming {
	var body: AnyView { get }
 }

extension ExistentialBox: AnyViewConforming where Content: View {
	fileprivate var body: AnyView { AnyView(content) }
}

extension AnyView {
	init?(any: Any) {
		guard let content = open(any, with: \AnyViewConforming.body) else { return nil }
		self = content
	}
}

// MARK: - SE-0352

extension AnyView {
	@MainActor
	init?(anySE0352 any: Any) {
		func open<T: View>(_ view: T) -> AnyView { .init(view) }
		guard let anyView = any as? (any View) else { return nil }
		self = open(anyView)
	}
}

// MARK: - SE-0335

extension AnyView {
	@MainActor
	init?(anySE0335 any: Any) {
		guard let anyView = any as? (any View) else { return nil }
		self = anyView.__eraseToAnyViewSE0335()
	}
}

private extension View {
	func __eraseToAnyViewSE0335() -> AnyView { .init(self) }
}

#endif
