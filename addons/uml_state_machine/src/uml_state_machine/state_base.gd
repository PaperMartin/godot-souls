class_name StateBase
extends UMLStateMachineBase
tool

var initial_transition: int setget set_initial_transition, get_initial_transition

var _initial_transition_path: NodePath
var _active_child_path: NodePath setget set_active_child_path
var _deferred_event_buffer := []

func set_initial_transition(new_initial_transition: int) -> void:
	if initial_transition != new_initial_transition:
		initial_transition = new_initial_transition
		update_initial_transition()
		property_list_changed_notify()
		update_configuration_warning()

func set_active_child_path(new_active_child_path: NodePath) -> void:
	if _active_child_path != new_active_child_path:
		_active_child_path = new_active_child_path

func get_initial_transition() -> int:
	var index = _get_state_child_paths().find(_initial_transition_path) + 1
	return index

func get_active_child_path() -> NodePath:
	return _active_child_path

func get_active_child() -> UMLStateMachineBase:
	if not is_active():
		return null

	if not has_node(_active_child_path):
		return null

	return get_node(_active_child_path) as UMLStateMachineBase

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["stateful"])

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "initial_transition",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(_get_state_child_path_names()).join(",")
		}
	] + ._get_property_list_internal()

func _get_configuration_warning() -> String:
	var parent = get_parent()
	if not parent.has_meta("stateful"):
		return "Stateful nodes must be attached to a State, Root or Region node"

	if get_child_count() > 0:
		var first_state_child = null
		for child in get_children():
			if child.has_meta("state"):
				first_state_child = child
				break

		if first_state_child:
			if _initial_transition_path.is_empty() or not has_node(_initial_transition_path) or not get_node(_initial_transition_path).get_parent() == self:
				return "Initial transition not set"

	return ""

func update_initial_transition() -> void:
	var states = _get_state_child_paths()
	if initial_transition >= 1 and initial_transition <= states.size():
		var state_path = states[initial_transition - 1]
		_initial_transition_path = state_path
	else:
		_initial_transition_path = NodePath()

func activate_with_initial_transition() -> void:
	if is_active():
		set_active_child_path(_initial_transition_path)

	for child in get_children():
		if child.has_meta("stateful"):
			child.activate_with_initial_transition()

func clear_active_child_path() -> void:
	set_active_child_path(NodePath())

func _exit_tree() -> void:
	if is_active():
		clear_active_child_path()

func _ready() -> void:
	._ready()

	if Engine.is_editor_hint():
		initialize()

func initialize() -> void:
	.initialize()

	for child in get_children():
		if child.has_meta("eventful"):
			if not child.type in _child_event_type_map:
				_child_event_type_map[child.type] = []
			_child_event_type_map[child.type].append(child)

	update_initial_transition()

func is_active() -> bool:
	var parent = get_parent()
	assert(parent.has_meta("stateful"))

	return parent.is_active() and parent.is_child_active(self)

func is_child_active(child: UMLStateMachineBase) -> bool:
	return is_active() and (_active_child_path == get_path_to(child) or child.has_meta("orthogonal_region") or child.has_meta("root"))

var _child_event_type_map := {}

func handle_event(event_type: int, args: Array = [], bubble: bool = true) -> void:
	#var debug_print = true

	if event_type in _child_event_type_map:
		for child in _child_event_type_map[event_type]:
			if event_type != UMLStateMachineEnums.EventType.Custom or args[0] == child._custom_event_name:
				if debug_print:
					print_debug("%s handling event of type %s with args %s" % [child.get_name(), UMLStateMachineEnums.EventType.keys()[event_type], args])

				if child.consume_event:
					bubble = false

				if child.evaluate(args):
					break

	if bubble:
		bubble_event(event_type, args)

func bubble_event(event_type: int, args: Array) -> void:
	pass

func defer_event(event_type: int, args: Array) -> void:
	_deferred_event_buffer.push_back([event_type, args])

func _get_state_child_paths() -> Array:
	var state_child_paths := []

	for child in get_children():
		if child.has_meta("state"):
			state_child_paths.append(get_path_to(child))

	return state_child_paths


func _get_state_child_path_names() -> PoolStringArray:
	var state_path_names = PoolStringArray(["[None]"])
	var state_child_paths = _get_state_child_paths()
	for state_child_path in state_child_paths:
		state_path_names.append(state_child_path.get_name(state_child_path.get_name_count() - 1))

	return state_path_names
