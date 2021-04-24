class_name Root, "res://addons/uml_state_machine/icons/root.svg"
extends StateBase
tool

signal custom_event(args)

# TODO: Limit transition dropdown options to children of first region ancestor

# TODO: Figure out how to encode If/Else, And/Or for guards
#		Current idea: Extend existing guard with child combinator options -
#		avoids adding new node and associated tree nesting

# TODO: Avoid needing to reload the scene after changing target script, implementation, or tree structure
#		Refresh cached lists when script resource changes

# TODO: Implement distinction between local and external transitions

# TODO: Debug drawing to visualize state, events

enum NotificationFlags {
	Process = 1,
	PhysicsProcess = 2,
	Input = 4,
	UnhandledInput = 8
}

var update setget set_update

var target_script: Script
var target_instance_path: NodePath
var custom_events: PoolStringArray

var notification_flags: int = NotificationFlags.Process | NotificationFlags.PhysicsProcess | NotificationFlags.Input | NotificationFlags.UnhandledInput

var _cached_target_script_method_list: Array
var _cached_target_script_property_list: Array
var _cached_state_child_list: Array
var _cached_state_parent_list: Array

var _event_buffer := []

func set_update(new_update: bool) -> void:
	if update != new_update:
		var leafs = get_leaf_stateful_descendants()
		for leaf in leafs:
			print_debug(leaf.get_name())

func get_target_script_method_list() -> Array:
	if not target_script:
		return []

	if _cached_target_script_method_list.empty():
		update_target_script_method_list()

	return _cached_target_script_method_list

func update_target_script_method_list() -> void:
	var script_method_list = target_script.get_script_method_list()
	script_method_list.sort_custom(self, "sort_dict_by_name_key")

	_cached_target_script_method_list = script_method_list

func get_target_script_property_list() -> Array:
	if not target_script:
		return []

	if _cached_target_script_property_list.empty():
		update_target_script_property_list()

	return _cached_target_script_property_list

func update_target_script_property_list() -> void:
	var script_property_list = target_script.get_script_property_list()
	script_property_list.sort_custom(self, "sort_dict_by_name_key")

	_cached_target_script_property_list = script_property_list

func get_state_child_list() -> Array:
	if _cached_state_child_list.empty():
		update_state_child_list()

	return _cached_state_child_list

func update_state_child_list() -> void:
	var state_children = get_state_children_recursive(self)
	for state_child in state_children:
		var node_path = get_path_to(state_child)
		_cached_state_child_list.append(node_path)

func get_state_parent_list() -> Array:
	if _cached_state_parent_list.empty():
		update_state_parent_list()

	return _cached_state_parent_list

func update_state_parent_list() -> void:
	var state_parents = get_state_parents_recursive(self)
	for state_parent in state_parents:
		var node_path = get_path_to(state_parent)
		_cached_state_parent_list.append(node_path)

func get_state_children_recursive(candidate: UMLStateMachineBase) -> Array:
	var state_children := []
	for child in candidate.get_children():
		if child.has_meta("state"):
			state_children.append(child)
		state_children += get_state_children_recursive(child)
	return state_children

func get_state_parents_recursive(candidate: UMLStateMachineBase) -> Array:
	var state_parents := []
	for child in candidate.get_children():
		if child.has_meta("state") and not candidate in state_parents:
			state_parents.append(candidate)

		var child_state_parents = get_state_parents_recursive(child)
		for child_state_parent in child_state_parents:
			if not child_state_parent in state_parents:
				state_parents.append(child_state_parent)
	return state_parents

func get_custom_event_list() -> Array:
	var root_descendants = UMLStateMachineUtil.get_root_descendants(self)
	var custom_event_list := Array(custom_events)
	custom_event_list.sort()

	for root_descendant in root_descendants:
		var descendant_event_list = root_descendant.get_custom_event_list()
		custom_event_list += descendant_event_list

	return custom_event_list

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "Root",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		},
		{
			"name": "update",
			"type": TYPE_BOOL
		},
		{
			"name": "target_script",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Script"
		},
		{
			"name": "target_instance_path",
			"type": TYPE_NODE_PATH
		},
		{
			"name": "custom_events",
			"type": TYPE_STRING_ARRAY
		},
		{
			"name": "notification_flags",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_FLAGS,
			"hint_string": PoolStringArray(NotificationFlags.keys()).join(",")
		}
	] + ._get_property_list_internal()

func _get_configuration_warning() -> String:
	var parent = get_parent()
	if parent is UMLStateMachineBase and not parent.has_meta("stateful"):
		return "Root nodes must be attached to a State, Root or Region node"

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


func is_active() -> bool:
	var parent = get_parent()
	if parent.has_meta("stateful"):
		return parent.is_active() and parent.is_child_active(self)
	return true

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["root"]) + ._get_meta_tags()


func get_target_instance() -> Node:
	var root_ancestor = UMLStateMachineUtil.get_root_ancestor(self)
	if root_ancestor:
		return root_ancestor.get_target_instance()

	if has_node(target_instance_path):
		return get_node(target_instance_path)
	return get_node(target_instance_path) if has_node(target_instance_path) else null


func sort_dict_by_name_key(lhs: Dictionary, rhs: Dictionary) -> bool:
	return lhs.name < rhs.name


func get_event_children(candidate: UMLStateMachineBase) -> Array:
	var event_children := []
	for child in candidate.get_children():
		if child.has_meta("event"):
			event_children.append(child)
	return event_children

func is_running() -> bool:
	if Engine.is_editor_hint():
		return false

	var target_instance = get_target_instance()
	if not target_instance:
		return false

	if not target_instance.is_inside_tree():
		return false

	if target_instance.is_queued_for_deletion():
		return false

	return true

func _ready() -> void:
	._ready()

	if not is_running():
		return

	# Topmost root node
	if not get_parent().has_meta("stateful"):
		set_process(notification_flags & NotificationFlags.Process)
		set_physics_process(notification_flags & NotificationFlags.PhysicsProcess)
		set_process_input(notification_flags & NotificationFlags.Input)
		set_process_unhandled_input(notification_flags & NotificationFlags.UnhandledInput)
	else:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		set_process_unhandled_input(false)

func initialize() -> void:
	.initialize()

	activate_with_initial_transition()
	buffer_event(UMLStateMachineEnums.EventType.Entry)
	dispatch_events()

func _exit_tree() -> void:
	if not is_running():
		return

	buffer_event(UMLStateMachineEnums.EventType.Exit)
	dispatch_events()

func _process(delta: float) -> void:
	if not is_running():
		return

	fire_process_event(delta)

func _physics_process(delta: float) -> void:
	if not is_running():
		return

	fire_physics_process_event(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not is_running():
		return

	fire_input_event(event)

func buffer_event(event_type: int, args: Array = []) -> void:
	if not is_running():
		return

	_event_buffer.push_back([event_type, args])

func fire_process_event(delta: float) -> void:
	buffer_event(UMLStateMachineEnums.EventType.Process, [delta])
	dispatch_events()

func fire_physics_process_event(delta: float) -> void:
	buffer_event(UMLStateMachineEnums.EventType.PhysicsProcess, [delta])
	dispatch_events()

func fire_input_event(event: InputEvent) -> void:
	buffer_event(UMLStateMachineEnums.EventType.InputAction, [event])
	dispatch_events()

func fire_custom_event(custom_event_name: String) -> void:
	if not is_running():
		return

	buffer_event(UMLStateMachineEnums.EventType.Custom, [custom_event_name])
	dispatch_events()

var _cached_leaf_stateful_descendants: Array
func get_leaf_stateful_descendants() -> Array:
	if _cached_leaf_stateful_descendants.empty():
		_cached_leaf_stateful_descendants = UMLStateMachineUtil.get_leaf_stateful_descendants(self)
	return _cached_leaf_stateful_descendants

func dispatch_events() -> void:
	if not is_running():
		return

	if debug_print:
		print_debug("Dispatching events: %s" % [_event_buffer])

	var leaf_stateful_descendants = get_leaf_stateful_descendants()

	var active_stateful_descendants := []
	for leaf in leaf_stateful_descendants:
		if leaf.is_active():
			active_stateful_descendants.append(leaf)

	while _event_buffer.size() > 0:
		var event = _event_buffer.pop_front()
		var event_type = event[0] as int
		var event_args = event[1] as Array
		for leaf in active_stateful_descendants:
			leaf.handle_event(event_type, event_args)

func bubble_event(event_type: int, args: Array) -> void:
	if not is_running():
		return

	match event_type:
		UMLStateMachineEnums.EventType.Custom:
			emit_signal("custom_event", args)
