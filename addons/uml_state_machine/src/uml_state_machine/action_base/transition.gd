class_name Transition, "res://addons/uml_state_machine/icons/transition.svg"
extends ActionBase
tool

enum TransitionType {
	Internal,
	External
}

var type: int = TransitionType.Internal
var target_state: int setget set_target_state

var _target_state_path: NodePath

func set_target_state(new_target_state: int) -> void:
	if target_state != new_target_state:
		target_state = new_target_state

		if is_inside_tree():
			update_target_state()
			update_name()

	update_configuration_warning()

func get_target_state() -> int:
	var index = UMLStateMachineUtil.get_root_state_child_list(self).find(_target_state_path) + 1
	return index

func update_target_state() -> void:
	var states = UMLStateMachineUtil.get_root_state_child_list(self)
	if target_state >= 1 and target_state <= states.size():
		var state_path = states[target_state - 1]
		_target_state_path = state_path
	else:
		_target_state_path = NodePath()

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["transition"])

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "Transition",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		},
		{
			"name": "type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(TransitionType.keys()).join(',')
		},
		{
			"name": "target_state",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": UMLStateMachineUtil.get_child_state_name_list(self).join(',')
		},
		{
			"name": "_target_state_path",
			"type": TYPE_NODE_PATH,
			"usage": PROPERTY_USAGE_NOEDITOR
		}
	] + ._get_property_list_internal()

func _get_configuration_warning() -> String:
	var parent = get_parent()
	if not parent.has_meta("event") and not parent.has_meta("guard"):
		return "Transition nodes must be parented to an Event or Guard node"

	if target_state <= 0:
		return "Target state not set"

	var root_ancestor = UMLStateMachineUtil.get_root_ancestor(self)
	if not root_ancestor:
		return "Transition nodes must have a Root ancestor"

	if not root_ancestor.has_node(_target_state_path):
		return "Target state path %s not valid" % [_target_state_path]

	return ""


func update_name() -> void:
	var states = UMLStateMachineUtil.get_root_state_child_list(self)
	if target_state >= 1 and target_state <= states.size():
		var root_ancestor = UMLStateMachineUtil.get_root_ancestor(self)
		var state_path = states[target_state - 1]
		name = String(state_path).replace("/", "|")
	else:
		name = "Transition"


func _ready() -> void:
	if Engine.is_editor_hint():
		target_state = get_target_state()
		update_target_state()
		update_name()

func initialize() -> void:
	.initialize()

	target_state = get_target_state()
	update_target_state()
	update_name()


func evaluate(args: Array = []) -> bool:
	.evaluate(args)

	#var debug_print = true

	if debug_print:
		print_debug("Transition %s evaluating with args %s" % [get_path(), args])
		print_debug("Transition to %s" % [get_name().replace("|", "/")])

	var root_ancestor = UMLStateMachineUtil.get_root_ancestor(self)
	assert(root_ancestor)

	var target_node = root_ancestor.get_node(_target_state_path)
	assert(target_node)
	var target_path = get_path_to(target_node)

	var stateful_ancestor = UMLStateMachineUtil.get_stateful_ancestor(self)
	assert(stateful_ancestor)

	var from_candidate = stateful_ancestor
	while true:
		if from_candidate.has_meta("stateful"):
			var candidate_child = from_candidate.get_active_child()
			if not candidate_child:
				break
			from_candidate = candidate_child

	if from_candidate == target_node:
		if type == TransitionType.External:
			# TODO: Proper external transitions
			#		Need to handle transitioning within subtree as well as the basic self-transition case
			#		Is self-transition a separate case from external transitions?
			target_node.handle_event(UMLStateMachineEnums.EventType.Exit, [], false)
			target_node.handle_event(UMLStateMachineEnums.EventType.Entry, [], false)
		return true

	var candidate = from_candidate
	target_path = candidate.get_path_to(target_node)

	if debug_print:
		print_debug("Target path: %s" % [target_path])

	var least_common_ancestor = null
	for i in range(0, target_path.get_name_count()):
		var path_name = target_path.get_name(i)
		var next_candidate = candidate.get_node(path_name)

		if candidate.has_meta("stateful"):
			if path_name == "..":
					# Walking up tree, dispatch exit events and deactivate states

					if debug_print:
						print_debug("Exiting %s" % [candidate.get_name()])
					candidate.handle_event(UMLStateMachineEnums.EventType.Exit, [], false)
					candidate.clear_active_child_path()
			else:
				if not least_common_ancestor:
					# Least common ancestor, evaluate actions associated with transition
					if debug_print:
						print_debug("Least Common Ancestor: %s" % [candidate.get_name()])
					least_common_ancestor = candidate
					candidate.set_active_child_path(candidate.get_path_to(next_candidate))

					for child in get_children():
						assert(child is UMLStateMachineBase)
						child.evaluate(args)
				else:
					# Walking down tree, activate nodes and dispatch entry events
					if debug_print:
						print_debug("Entering %s" % [candidate.get_name()])
					candidate.handle_event(UMLStateMachineEnums.EventType.Entry, [], false)
					candidate.set_active_child_path(candidate.get_path_to(next_candidate))

		candidate = next_candidate

	if debug_print:
		print_debug("Entering %s" % [candidate.get_name()])
	candidate.handle_event(UMLStateMachineEnums.EventType.Entry, [], false)

	# Drill down to leaf node using initial transitions
	if candidate._active_child_path.is_empty():
		while candidate.has_node(candidate._initial_transition_path):
			var next_candidate = candidate.get_node(candidate._initial_transition_path)

			if debug_print:
				print_debug("Entering %s" % [next_candidate.get_name()])
			candidate.set_active_child_path(candidate._initial_transition_path)
			next_candidate.handle_event(UMLStateMachineEnums.EventType.Entry, [], false)

			candidate = next_candidate

	if least_common_ancestor:
		while least_common_ancestor._deferred_event_buffer.size() > 0:
			var event = least_common_ancestor._deferred_event_buffer.pop_front()
			var event_type = event[0] as int
			var event_args = event[1] as Array
			root_ancestor.buffer_event(event_type, event_args)

	root_ancestor.dispatch_events()

	return true
