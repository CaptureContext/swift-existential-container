import Testing
@testable import ExistentialContainer

#if canImport(SwiftUI)
import SwiftUI
#endif

@Suite("ExistentialContainerTests")
struct ExistentialContainerTests {
	#if canImport(SwiftUI)
	@Test
	func testSwiftUIAnyView() async throws {
		let text = Text("")
		let anyText: Any = text
		#expect(AnyView(any: anyText) != nil)
	}
	#endif


	@Test
	func testMutuallyDependantTypes() async throws {
		let component = SomeComponent()
		let model = SomeComponent.Model()

		let anyComponent: any UIComponent = component
		let anyModel: any UIComponentModel = model

		ExistentialBox(anyComponent).setModel(anyModel)

		#expect(component.model === model)
	}
}

private final class SomeComponent: UIComponent {
	final class Model: UIComponentModel {
		typealias Component = SomeComponent
	}

	init() {}

	var model: Model?

	func setModel(_ model: Model) {
		self.model = model
	}
}
