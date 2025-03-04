/// Container opening existentials
///
/// By leveraging power of conditional conformances this type serves as a castable container for `_openExistential`  function
///
/// Examples:
///
/// ```swift
/// import SwiftUI
///
/// // Declare required type-erased properties or methods in a separate private protocol
///
/// private protocol AnyViewConforming {
///   var body: AnyView { get }
/// }
///
/// // Conform `ExistentialBox` to given protocol when Content conforms/inherits base protocol/type
/// extension ExistentialBox: AnyViewConforming where Content: View {
///   fileprivate var body: AnyView { AnyView(content) }
/// }
///
/// // Use `open` function to access/process data
/// extension AnyView {
///   init?(any: Any) {
///     guard let content = open(any, \AnyViewConforming.content) else { return nil }
///     self = content
///   }
/// }
/// ```
///
/// Similarly you can process mutually-dependant generic types
///
/// ```swift
/// // MARK: - Declaration
///
/// public protocol InitializableWithNoArguments {
///   init()
/// }
///
/// public protocol UIComponent<Model>: InitializableWithNoArguments {
///   associatedtype Model: UIComponentModel<Self>
///   func setModel(_ model: Model)
/// }
///
/// public protocol UIComponentModel<Component> {
///   associatedtype Component: UIComponent<Self>
///   func createComponent() -> Component
/// }
///
/// extension UIComponentModel {
///   public func createComponent() -> Component {
///     let component = Component()
///     component.setModel(self)
///     return component
///   }
/// }
///
/// // MARK: - Opening existentials (probably a separate file)
///
/// private protocol UIComponentConforming {
///   func setAnyModel(_ model: any UIComponentModel)
/// }
///
/// extension ExistentialBox: UIComponentConforming where Content: UIComponent {
///   fileprivate func setAnyModel(_ model: any UIComponentModel) {
///     (model as? Content.Model).map(content.setModel)
///   }
/// }
///
/// extension ExistentialBox<(any UIComponent)> {
///   public func setModel(_ model: any UIComponentModel) {
///     ExistentialBox<UIComponentConforming>.open(content) { $0.setAnyModel(model) }
///   }
/// }
/// ```
public struct ExistentialBox<Content> {
	public let content: Content

	public init(_ content: Content) {
		self.content = content
	}
}

extension ExistentialBox {
	public static func open<Output>(
		_ value: Any,
		as targetType: Content.Type = Content.self,
		with action: (Content) -> Output
	) -> Output? {
		ExistentialContainer.open(value, as: targetType, with: action)
	}
}
