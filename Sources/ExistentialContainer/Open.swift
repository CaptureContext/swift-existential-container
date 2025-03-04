/// Opens an existential and returns result
///
/// - Parameters:
///   - value: Value to open
///   - type: Target type to cast value to
///   - action: Action to perform on casted type
///
/// - Returns: Result of action if cast was successfull
public func open<Target, Output>(
	_ value: Any,
	as targetType: Target.Type = Target.self,
	with action: (Target) -> Output
) -> Output? {
	func unbox<T>(_ value: T) -> Output? {
		(ExistentialBox<T>(value) as? Target).map(action)
	}

	return _openExistential(value, do: unbox)
}

/// Opens an existential
///
/// - Parameters:
///   - value: Value to open
///   - type: Target type to cast value to
///   - action: Action to perform on casted type
public func open<Target>(
	_ value: Any,
	as targetType: Target.Type = Target.self,
	with action: (Target) -> Void
) {
	func unbox<T>(_ value: T) {
		(ExistentialBox<T>(value) as? Target).map(action)
	}

	_openExistential(value, do: unbox)
}
