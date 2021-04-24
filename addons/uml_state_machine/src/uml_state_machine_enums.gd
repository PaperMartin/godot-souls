class_name UMLStateMachineEnums

enum EventType {
	Entry,
	Exit,
	Process,
	PhysicsProcess,
	InputAction,
	Custom
}

enum GuardType {
	Property,
	Method,
	InputAction,
	State
}

enum InputActionType {
	Pressed,
	Released,
	Strength
}

enum LogicalOperator {
	And,
	Or
}

enum ComparisonOperator {
	Equal,
	NotEqual,
	Greater,
	GreaterOrEqual,
	Lesser,
	LesserOrEqual
}
