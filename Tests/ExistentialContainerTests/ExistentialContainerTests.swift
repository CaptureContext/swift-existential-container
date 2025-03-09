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

	@MainActor
	@Test
	func testSwiftUIAnyViewSE0352() async throws {
		let text = Text("")
		let anyText: Any = text
		#expect(AnyView(anySE0352: anyText) != nil)
	}

	@MainActor
	@Test
	func testSwiftUIAnyViewSE0335() async throws {
		let text = Text("")
		let anyText: Any = text
		#expect(AnyView(anySE0335: anyText) != nil)
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

	@Test
	func testMutuallyDependantTypesSE0352() async throws {
		let component = SomeComponent()
		let model = SomeComponent.Model()

		let anyComponent: any UIComponent = component
		let anyModel: any UIComponentModel = model

		setAnyModelSE0352(anyModel, to: anyComponent)

		#expect(component.model === model)
	}

	@Test
	func testMutuallyDependantTypesSE0335() async throws {
		let component = SomeComponent()
		let model = SomeComponent.Model()

		let anyComponent: any UIComponent = component
		let anyModel: any UIComponentModel = model

		anyComponent.setAnyModelSE0335(anyModel)

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
