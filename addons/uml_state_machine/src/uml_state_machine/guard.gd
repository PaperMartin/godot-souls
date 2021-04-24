class_name Guard, "res://addons/uml_state_machine/icons/guard.svg"
extends UMLStateMachineBase
tool

var type: int = UMLStateMachineEnums.GuardType.Property setget set_type

var property: int setget set_property
var property_subnames: String setget set_property_subnames
var property_comparator: Resource setget set_property_comparator

var method: int setget set_method
var method_arguments: Array setget set_method_arguments, get_method_arguments
var method_comparator: Resource setget set_method_comparator

var input_action: int setget set_input_action
var input_action_type: int setget set_input_action_type
var strength_comparator: Resource setget set_strength_comparator

var state: int setget set_state
var state_operator: int
var state_child: int setget set_state_child

var _property_name: String
var _method_name: String
var _input_action_name: String
var _state_path: NodePath
var _state_child_path: NodePath

# Setters
func set_type(new_type: int) -> void:
	if type != new_type:
		type = new_type
		if Engine.is_editor_hint():
			property_list_changed_notify()
			update_configuration_warning()

func set_property(new_property: int) -> void:
	if property != new_property:
		property = new_property

		if Engine.is_editor_hint():
			update_property_name()
			update_property_comparator()
			property_list_changed_notify()

	if Engine.is_editor_hint():
		update_configuration_warning()

func set_property_subnames(new_property_subnames: String) -> void:
	if property_subnames != new_property_subnames:
		property_subnames = new_property_subnames

		if Engine.is_editor_hint():
			update_property_comparator()
			property_list_changed_notify()

	if Engine.is_editor_hint():
		update_configuration_warning()

func set_property_comparator(new_property_comparator: Resource) -> void:
	if Engine.is_editor_hint():
		if not new_property_comparator or not new_property_comparator as Comparator:
			new_property_comparator = Comparator.new()

		if property_comparator != new_property_comparator:
			property_comparator = new_property_comparator.duplicate()
	else:
		property_comparator = new_property_comparator

func set_method(new_method: int) -> void:
	if method != new_method:
		method = new_method

		var method_names = UMLStateMachineUtil.get_method_names(self)
		if method >= 0 and method < method_names.size():
			_method_name = method_names[method]

		if Engine.is_editor_hint():
			update_method_comparator()
			property_list_changed_notify()

	if Engine.is_editor_hint():
		update_configuration_warning()

func set_method_arguments(new_method_arguments: Array) -> void:
	if method_arguments != new_method_arguments:
		method_arguments = new_method_arguments

	if Engine.is_editor_hint():
		update_configuration_warning()

func set_method_comparator(new_method_comparator: Resource) -> void:
	if Engine.is_editor_hint():
		if not new_method_comparator or not new_method_comparator as Comparator:
			new_method_comparator = Comparator.new()

		if method_comparator != new_method_comparator:
			method_comparator = new_method_comparator.duplicate()
	else:
		method_comparator = new_method_comparator

func noop_setter(_ignore: Resource) -> void:
	pass

func set_input_action(new_input_action: int) -> void:
	if input_action != new_input_action:
		input_action = new_input_action

		var input_action_names = UMLStateMachineUtil.get_input_action_names()
		if input_action >= 0 and input_action < input_action_names.size():
			_input_action_name = input_action_names[input_action]

		if Engine.is_editor_hint():
			update_configuration_warning()

func set_input_action_type(new_input_action_type: int) -> void:
	if input_action_type != new_input_action_type:
		input_action_type = new_input_action_type
		if Engine.is_editor_hint():
			property_list_changed_notify()
			update_configuration_warning()

func set_strength_comparator(new_strength_comparator: Resource) -> void:
	if Engine.is_editor_hint():
		if not new_strength_comparator or not new_strength_comparator as Comparator:
			new_strength_comparator = Comparator.new()
			new_strength_comparator.type = TYPE_REAL

		if strength_comparator != new_strength_comparator:
			strength_comparator = new_strength_comparator.duplicate()
	else:
		strength_comparator = new_strength_comparator

func set_state(new_state: int) -> void:
	if state != new_state:
		state = new_state

		if Engine.is_editor_hint():
			update_state_path()

			property_list_changed_notify()
			update_configuration_warning()

func set_state_child(new_state_child: int) -> void:
	if state_child != new_state_child:
		state_child = new_state_child

		if Engine.is_editor_hint():
			update_state_child_path()
			update_configuration_warning()

# Getters
func get_method_arguments() -> Array:
	var target_script_methods = UMLStateMachineUtil.get_root_target_script_methods(self)

	var target_method = UMLStateMachineUtil.get_target_script_method(self, _method_name)
	if target_method.empty():
		return []

	var new_arguments = method_arguments

	if new_arguments.size() != target_method.args.size():
		new_arguments.resize(target_method.args.size())

	for i in range(0, new_arguments.size()):
		if typeof(new_arguments[i]) != target_method.args[i].type:
			new_arguments[i] = UMLStateMachineUtil.get_type_default(target_method.args[i].type)
	return new_arguments

func update_property_name() -> void:
	var property_names = UMLStateMachineUtil.get_property_names(self)
	if property >= 0 and property < property_names.size():
		_property_name = property_names[property]

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["guard"])

# Update Functions
func update_property() -> void:
	property = max(UMLStateMachineUtil.get_property_names(self).find(_property_name), 0)

func update_method() -> void:
	method = max(UMLStateMachineUtil.get_method_names(self).find(_method_name), 0)

func update_input_action() -> void:
	input_action = max(UMLStateMachineUtil.get_input_action_names().find(_input_action_name), 0)

func update_state() -> void:
	state = UMLStateMachineUtil.get_root_state_parent_list(self).find(_state_path) + 1

func update_state_child() -> void:
	state_child = _get_state_child_paths().find(_state_child_path) + 1

func update_property_comparator() -> void:
	property_comparator.type = _get_target_property_type()

func update_method_comparator() -> void:
	method_comparator.type = _get_target_method_type()

func update_state_path() -> void:
	var states = UMLStateMachineUtil.get_root_state_parent_list(self)
	if state >= 1 and state <= states.size():
		var state_path = states[state - 1]
		_state_path = state_path
	else:
		_state_path = ""

func update_state_child_path() -> void:
	var states = _get_state_child_paths()
	if state_child >= 1 and state_child <= states.size():
		var state_path = states[state_child - 1]
		_state_child_path = state_path
	else:
		_state_child_path = ""

# Overrides
func _init() -> void:
	property_comparator = Comparator.new()
	method_comparator = Comparator.new()

	strength_comparator = Comparator.new()
	strength_comparator.type = TYPE_REAL

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		update_property_comparator()
		update_method_comparator()

func _ready() -> void:
	if Engine.is_editor_hint():
		update_property()
		update_method()
		update_input_action()
		update_state()
		update_state_child()

func initialize() -> void:
	.initialize()

	update_property()
	update_method()
	update_input_action()
	update_state()
	update_state_child()

func _get_property_list_internal() -> Array:
	var property_list := []

	property_list.append({
			"name": "Guard",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
	})

	property_list.append({
		"name": "type",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": PoolStringArray(UMLStateMachineEnums.GuardType.keys()).join(',')
	})

	match type:
		UMLStateMachineEnums.GuardType.Property:
			property_list.append({
				"name": "property",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": UMLStateMachineUtil.get_properties_enum_string(self)
			})
			property_list.append({
				"name": "property_subnames",
				"type": TYPE_STRING,
			})
			property_list.append({
				"name": "property_comparator",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Resource"
			})
		UMLStateMachineEnums.GuardType.Method:
			property_list.append({
				"name": "method",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": UMLStateMachineUtil.get_methods_enum_string(self)
			})
			property_list.append({
				"name": "method_arguments",
				"type": TYPE_ARRAY
			})
			property_list.append({
				"name": "method_comparator",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Resource"
			})
		UMLStateMachineEnums.GuardType.InputAction:
			property_list.append({
				"name": "input_action",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": PoolStringArray(UMLStateMachineUtil.get_input_action_names()).join(',')
			})
			property_list.append({
				"name": "input_action_type",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": PoolStringArray(UMLStateMachineEnums.InputActionType.keys()).join(',')
			})
			if input_action_type == UMLStateMachineEnums.InputActionType.Strength:
				property_list.append({
					"name": "strength_comparator",
					"type": TYPE_OBJECT,
					"hint": PROPERTY_HINT_RESOURCE_TYPE,
					"hint_string": "Resource"
				})
		UMLStateMachineEnums.GuardType.State:
			property_list.append({
				"name": "state",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": PoolStringArray(UMLStateMachineUtil.get_parent_state_name_list(self)).join(',')
			})
			property_list.append({
				"name": "state_operator",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": PoolStringArray(UMLStateMachineEnums.ComparisonOperator.keys().slice(0, 1)).join(",")
			})
			property_list.append({
				"name": "state_child",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": PoolStringArray(_get_state_child_path_names()).join(',')
			})

	property_list.append({
		"name": "_property_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_NOEDITOR
	})

	property_list.append({
		"name": "_method_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_NOEDITOR
	})

	property_list.append({
		"name": "_input_action_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_NOEDITOR
	})

	property_list.append({
		"name": "_state_path",
		"type": TYPE_NODE_PATH,
		"usage": PROPERTY_USAGE_NOEDITOR
	})

	property_list.append({
		"name": "_state_child_path",
		"type": TYPE_NODE_PATH,
		"usage": PROPERTY_USAGE_NOEDITOR
	})


	return property_list + ._get_property_list_internal()

func _get_property_subnames_array() -> PoolStringArray:
	return property_subnames.split(':')

func _get_configuration_warning() -> String:
	var parent = get_parent()
	if not parent.has_meta("event") and not parent.has_meta("guard") and not parent.has_meta("transition"):
		return "Guard nodes must be parented to an Event, Guard or Transition node"

	var event_ancestor = UMLStateMachineUtil.get_event_ancestor(self)
	if not event_ancestor:
		return "Guard nodes must have an Event node ancestor"

	match type:
		UMLStateMachineEnums.GuardType.Property:
			if property <= 0:
				return "No property set"

			var target_script_properties = UMLStateMachineUtil.get_root_target_script_properties(self)
			var target_property = null
			for script_property in target_script_properties:
				if script_property.name == _property_name:
					target_property = script_property
					break

			if not target_property:
				return "Target method not present in script"

		UMLStateMachineEnums.GuardType.Method:
			if method <= 0:
				return "No method set"

			var target_method = UMLStateMachineUtil.get_target_script_method(self, _method_name)
			if target_method.empty():
				return "Target method not present in script"

			if method_arguments.size() != target_method.args.size():
				return "Method takes %s args, but arguments array is of length %s" % [target_method.args.size(), method_arguments.size()]

			for i in range(0, method_arguments.size()):
				if typeof(method_arguments[i]) != target_method.args[i].type:
					return "Argument %s is of type %s, but method argument %s is of type %s" % [i, typeof(method_arguments[i]), i, target_method.args[i].type]

		UMLStateMachineEnums.GuardType.InputAction:
			if input_action <= 0:
				return "No input action set"

		UMLStateMachineEnums.GuardType.State:
			if state <= 0:
				return "No state path set"

			if state_child <= 0:
				return "No state comparator set"

	return ""

func _get_target_property() -> Dictionary:
	var target_script_properties = UMLStateMachineUtil.get_root_target_script_properties(self)
	var target_property = null
	for script_property in target_script_properties:
		if script_property.name == _property_name:
			return script_property

	return {}

func _get_target_method() -> Dictionary:
	var target_script_methods = UMLStateMachineUtil.get_root_target_script_methods(self)
	var target_method = null
	for script_method in target_script_methods:
		if script_method.name == _method_name:
			return script_method

	return {}

func _get_target_property_type() -> int:
	var target_property = _get_target_property()
	if not target_property:
		return TYPE_NIL
	return _get_subname_type(target_property.type, _get_property_subnames_array())

func _get_target_method_type() -> int:
	var target_method = _get_target_method()
	if not target_method:
		return TYPE_NIL
	return target_method["return"].type

func _get_subname_type(type: int, subnames: PoolStringArray) -> int:
	match type:
		TYPE_VECTOR2:
			if _test_subname(subnames, ["x", "y"]):
				return TYPE_REAL
		TYPE_RECT2:
			if _test_subname(subnames, ["position", "size", "end"]):
				subnames.remove(0)
				if _test_subname(subnames, ["x", "y"]):
					return TYPE_REAL
				return TYPE_VECTOR2
		TYPE_VECTOR3:
			if _test_subname(subnames, ["x", "y", "z"]):
				return TYPE_REAL
		TYPE_TRANSFORM2D:
			if _test_subname(subnames, ["origin", "x", "y"]):
				subnames.remove(0)
				if _test_subname(subnames, ["x", "y"]):
					return TYPE_REAL
				return TYPE_VECTOR2
		TYPE_PLANE:
			if _test_subname(subnames, ["x", "y", "z", "d"]):
				return TYPE_REAL

			if _test_subname(subnames, ["normal"]):
				subnames.remove(0)
				if _test_subname(subnames, ["x", "y", "z"]):
					return TYPE_REAL
				return TYPE_VECTOR3
		TYPE_QUAT:
			if _test_subname(subnames, ["x", "y", "z", "w"]):
				return TYPE_REAL
		TYPE_AABB:
			if _test_subname(subnames, ["position", "size", "end"]):
				subnames.remove(0)
				if _test_subname(subnames, ["x", "y", "z"]):
					return TYPE_REAL
				return TYPE_VECTOR3
		TYPE_BASIS:
			if _test_subname(subnames, ["x", "y", "z"]):
				subnames.remove(0)
				if _test_subname(subnames, ["x", "y", "z"]):
					return TYPE_REAL
				return TYPE_VECTOR3
		TYPE_TRANSFORM:
			if _test_subname(subnames, ["basis"]):
				return TYPE_BASIS

			if _test_subname(subnames, ["origin"]):
				subnames.remove(0)
				if _test_subname(subnames, ["x", "y", "z"]):
					return TYPE_REAL
				return TYPE_VECTOR3
		TYPE_COLOR:
			if _test_subname(subnames, ["r", "g", "b", "a", "h", "s", "v"]):
				return TYPE_REAL

			if _test_subname(subnames, ["r8", "g8", "b8", "a8"]):
				return TYPE_REAL
		TYPE_RAW_ARRAY:
			if typeof(subnames[0]) == TYPE_INT:
				return TYPE_INT
		TYPE_INT_ARRAY:
			if typeof(subnames[0]) == TYPE_INT:
				return TYPE_INT
		TYPE_REAL_ARRAY:
			if typeof(subnames[0]) == TYPE_INT:
				return TYPE_REAL
		TYPE_STRING_ARRAY:
			if typeof(subnames[0]) == TYPE_INT:
				return TYPE_STRING
		TYPE_VECTOR2_ARRAY:
			if typeof(subnames[0]) == TYPE_INT:
				return TYPE_VECTOR2
		TYPE_VECTOR3_ARRAY:
			if typeof(subnames[0]) == TYPE_INT:
				return TYPE_VECTOR3
		TYPE_COLOR_ARRAY:
			if typeof(subnames[0]) == TYPE_INT:
				return TYPE_COLOR
	return type

func _test_subname(subnames: PoolStringArray, comps: PoolStringArray) -> bool:
	if subnames.size() == 0:
		return false

	for comp in comps:
		if subnames[0] == comp:
			return true

	return false

func evaluate(args: Array = []) -> bool:
	.evaluate(args)

	#var debug_print = true

	if debug_print:
		DebugOverlay.print_log("Guard %s evaluating with args %s" % [get_path(), args])

	var target_instance = UMLStateMachineUtil.get_root_target_instance(self)
	if not target_instance:
		return false

	match type:
		UMLStateMachineEnums.GuardType.Property:
			var value = target_instance.get(_property_name)
			var subnames = _get_property_subnames_array()
			while subnames.size() > 0:
				var subname = subnames[0]
				subnames.remove(0)
				if subname.empty():
					continue
				value = value[subname]

			if debug_print:
				DebugOverlay.print_log("Evaluating property comparator with type %s, operator %s and value %s for property %s, subname %s (%s)" % [property_comparator.type, property_comparator.operator, property_comparator.get_value(), _property_name, property_subnames, value])

			var result = property_comparator.evaluate(value)
			if debug_print:
				DebugOverlay.print_log("Result: %s" % [result])

			if not result:
				return false

		UMLStateMachineEnums.GuardType.Method:
			var value = target_instance.callv(_method_name, method_arguments)

			if debug_print:
				DebugOverlay.print_log("Evaluating method comparator with type %s, operator %s and value %s for method %s" % [method_comparator.type, method_comparator.operator, method_comparator.get_value(), _method_name])

			if not method_comparator.evaluate(value):
				return false

		UMLStateMachineEnums.GuardType.InputAction:
			if args.size() > 0 and args[0] is InputEvent:
				match input_action_type:
					UMLStateMachineEnums.InputActionType.Pressed:
						if not args[0].is_action_pressed(_input_action_name):
							return false
					UMLStateMachineEnums.InputActionType.Released:
						if not args[0].is_action_released(_input_action_name):
							return false
					UMLStateMachineEnums.InputActionType.Strength:
						if args[0].is_action(input_action):
							var strength = args[0].get_action_strength(_input_action_name)
							if not strength_comparator.evaluate(strength):
								return false
			else:
				match input_action_type:
					UMLStateMachineEnums.InputActionType.Pressed:
						if not Input.is_action_pressed(_input_action_name):
							return false
					UMLStateMachineEnums.InputActionType.Released:
						if Input.is_action_pressed(_input_action_name):
							return false
					UMLStateMachineEnums.InputActionType.Strength:
						var strength = Input.get_action_strength(_input_action_name)
						if not strength_comparator.evaluate(strength):
							return false

		UMLStateMachineEnums.GuardType.State:
			if not evaluate_active_child_state(_state_path):
				return false

	for child in get_children():
		assert(child is UMLStateMachineBase)
		if child.evaluate(args):
			return true

	return false

func evaluate_logical_operator(operator: int, lhs, rhs) -> bool:
	match operator:
		UMLStateMachineEnums.ComparisonOperator.Equal:
			return lhs == rhs
		UMLStateMachineEnums.ComparisonOperator.NotEqual:
			return lhs != rhs
		UMLStateMachineEnums.ComparisonOperator.Greater:
			return lhs > rhs
		UMLStateMachineEnums.ComparisonOperator.GreaterOrEqual:
			return lhs >= rhs
		UMLStateMachineEnums.ComparisonOperator.Lesser:
			return lhs < rhs
		UMLStateMachineEnums.ComparisonOperator.LesserOrEqual:
			return lhs <= rhs
	return false

func evaluate_active_child_state(lhs: NodePath) -> bool:
	var root_ancestor = UMLStateMachineUtil.get_root_ancestor(self)
	assert(root_ancestor)

	var lhs_node = root_ancestor.get_node(lhs)
	assert(lhs_node)

	if lhs_node.is_active():
		lhs_node = lhs_node.get_node(lhs_node.get_active_child_path())
		assert(lhs_node)
	else:
		lhs_node = null

	var rhs_node = root_ancestor.get_node(_state_child_path)
	assert(rhs_node)

	match state_operator:
		UMLStateMachineEnums.ComparisonOperator.Equal:
			return lhs_node == rhs_node
		UMLStateMachineEnums.ComparisonOperator.NotEqual:
			return lhs_node != rhs_node
		UMLStateMachineEnums.ComparisonOperator.Greater:
			return lhs_node > rhs_node
		UMLStateMachineEnums.ComparisonOperator.GreaterOrEqual:
			return lhs_node >= rhs_node
		UMLStateMachineEnums.ComparisonOperator.Lesser:
			return lhs_node < rhs_node
		UMLStateMachineEnums.ComparisonOperator.LesserOrEqual:
			return lhs_node <= rhs_node

	return false

func _get_state_child_paths() -> Array:
	var state_child_paths := []

	var root_ancestor = UMLStateMachineUtil.get_root_ancestor(self)
	if not root_ancestor or not root_ancestor.has_node(_state_path):
		return state_child_paths

	var target_state = root_ancestor.get_node(_state_path)
	for child in target_state.get_children():
		if child.has_meta("state"):
			state_child_paths.append(root_ancestor.get_path_to(child))

	return state_child_paths


func _get_state_child_path_names() -> PoolStringArray:
	var state_path_names = PoolStringArray(["[None]"])
	var state_child_paths = _get_state_child_paths()
	for state_child_path in state_child_paths:
		state_path_names.append(state_child_path.get_name(state_child_path.get_name_count() - 1))

	return state_path_names
