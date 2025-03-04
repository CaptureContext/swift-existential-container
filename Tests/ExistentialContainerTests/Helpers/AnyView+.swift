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

#endif
