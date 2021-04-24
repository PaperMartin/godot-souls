class_name InternalTransition, "res://addons/uml_state_machine/icons/internal_transition.svg"
extends ActionBase
tool


var method: int setget set_method
var arguments: Array setget set_arguments,get_arguments

var _method_name: String

func set_method(new_method: int) -> void:
	if method != new_method:
		method = new_method

		update_method_name()
		update_name()
		property_list_changed_notify()
		update_configuration_warning()


func set_arguments(new_arguments: Array) -> void:
	if arguments != new_arguments:
		arguments = new_arguments

		update_configuration_warning()


func get_arguments() -> Array:
	var target_script_methods = UMLStateMachineUtil.get_root_target_script_methods(self)

	var target_method = UMLStateMachineUtil.get_target_script_method(self, _method_name)
	if target_method.empty():
		return []

	var new_arguments = arguments

	var arg_count_offset = get_arg_count_offset()
	if new_arguments.size() != target_method.args.size() - arg_count_offset:
		new_arguments.resize(target_method.args.size() - arg_count_offset)

	for i in range(arg_count_offset, target_method.args.size()):
		if typeof(new_arguments[i - arg_count_offset]) != target_method.args[i].type:
			new_arguments[i - arg_count_offset] = UMLStateMachineUtil.get_type_default(target_method.args[i].type)
	return new_arguments

func update_method() -> void:
	method = UMLStateMachineUtil.get_method_names(self).find(_method_name)

func update_method_name() -> void:
	var method_names = UMLStateMachineUtil.get_method_names(self)
	if method >= 1 and method <= method_names.size():
		_method_name = method_names[method]
	else:
		_method_name = ""

func update_name():
	if _method_name.empty():
		name = "InternalTransition"
	else:
		name = _method_name.capitalize().replace(" ", "")

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["internal_transition"])

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "InternalTransition",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		},
		{
			"name": "method",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": UMLStateMachineUtil.get_methods_enum_string(self)
		},
		{
			"name": "arguments",
			"type": TYPE_ARRAY
		},
		{
			"name": "_method_name",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_NOEDITOR
		}
	] + ._get_property_list_internal()

func _get_configuration_warning() -> String:
	var parent = get_parent()
	if not parent.has_meta("event") and not parent.has_meta("guard") and not parent.has_meta("transition"):
		return "InternalTransition nodes must be parented to an Event, Guard or Transition node"

	var event_ancestor = UMLStateMachineUtil.get_event_ancestor(self)
	if not event_ancestor:
		return "InternalTransition nodes must have an Event ancestor"

	if method <= 0:
		return "No method set"

	var target_method = UMLStateMachineUtil.get_target_script_method(self, _method_name)

	if target_method.empty():
		return "Target method not present in script"

	var arg_count_offset = get_arg_count_offset()
	if arguments.size() < target_method.args.size() - arg_count_offset:
		return "Method takes %s args (%s provided by ancestor nodes), but arguments array is of length %s" % [target_method.args.size() - arg_count_offset, arg_count_offset, arguments.size()]

	for i in range(arg_count_offset, target_method.args.size()):
		if typeof(arguments[i - arg_count_offset]) != target_method.args[i].type:
			return "Argument %s is of type %s, but method argument %s is of type %s" % [i, typeof(arguments[i]), i, target_method.args[i].type]

	return ""

func get_arg_count_offset() -> int:
	var event_ancestor = UMLStateMachineUtil.get_event_ancestor(self)
	if not event_ancestor:
		return 0

	var arg_count_offset = 0
	match event_ancestor.type:
		UMLStateMachineEnums.EventType.PhysicsProcess:
			arg_count_offset = 1
		UMLStateMachineEnums.EventType.Process:
			arg_count_offset = 1
		UMLStateMachineEnums.EventType.InputAction:
			arg_count_offset = 1
	return arg_count_offset

func _ready() -> void:
	._ready()

	if Engine.is_editor_hint():
		update_method()
		update_name()

func evaluate(args: Array = []) -> bool:
	.evaluate(args)

	#var debug_print = true

	if debug_print:
		print_debug("InternalTransition %s evaluating with args %s" % [get_path(), args])

	if not _method_name.empty():
		var target_instance = UMLStateMachineUtil.get_root_target_instance(self)
		if not target_instance:
			return false

		var new_args = args + arguments
		var target_method = UMLStateMachineUtil.get_target_script_method(self, _method_name)
		if target_method.args.size() == 0:
			target_instance.call(_method_name)
		else:
			target_instance.callv(_method_name, new_args.slice(0, target_method.args.size() - 1))

	return false
