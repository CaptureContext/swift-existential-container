import ExistentialContainer

private protocol UIComponentConforming {
	func setAnyModel(_ model: any UIComponentModel)
}

extension ExistentialBox: UIComponentConforming where Content: UIComponent {
	fileprivate func setAnyModel(_ model: any UIComponentModel) {
		(model as? Content.Model).map(content.setModel)
	}
}

extension ExistentialBox<(any UIComponent)> {
	public func setModel(_ model: any UIComponentModel) {
		ExistentialBox<UIComponentConforming>.open(content) { $0.setAnyModel(model) }
	}
}

// MARK: - SE-0352

func setAnyModelSE0352<
	Component: UIComponent,
	Model: UIComponentModel
>(
	_ model: Model,
	to component: Component
) {
	(model as? Component.Model).map(component.setModel)
}

// MARK: - SE-0335

extension UIComponent {
	func setAnyModelSE0335(_ model: any UIComponentModel) {
		(model as? Model).map(setModel)
	}
}
