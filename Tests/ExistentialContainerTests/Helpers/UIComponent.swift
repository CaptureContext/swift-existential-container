public protocol InitializableWithNoArguments {
	init()
}

public protocol UIComponent<Model>: InitializableWithNoArguments {
	associatedtype Model: UIComponentModel<Self>
	func setModel(_ model: Model)
}

public protocol UIComponentModel<Component> {
	associatedtype Component: UIComponent<Self>
	func createComponent() -> Component
}

extension UIComponentModel {
	public func createComponent() -> Component {
		let component = Component()
		component.setModel(self)
		return component
	}
}
