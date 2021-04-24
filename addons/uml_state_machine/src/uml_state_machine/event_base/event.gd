class_name Event, "res://addons/uml_state_machine/icons/event.svg"
extends EventBase
tool


func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["event"]) + ._get_meta_tags()

func _get_configuration_warning() -> String:
	if not get_parent() as Root and not get_parent() as Region and not get_parent() as State:
		return "Event nodes must be children of Root, Region, or State"

	return ""

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "Event",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		}
	] + ._get_property_list_internal()

func evaluate(args: Array = []) -> bool:
	.evaluate(args)

	#var debug_print = true

	if debug_print:
		print_debug("Event %s evaluating with args %s" % [get_path(), args])

	if type == UMLStateMachineEnums.EventType.Custom:
		if args[0] != _custom_event_name:
			return false

	for child in get_children():
		assert(child is UMLStateMachineBase)
		if child.evaluate(args):
			return true

	return false
