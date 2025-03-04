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
