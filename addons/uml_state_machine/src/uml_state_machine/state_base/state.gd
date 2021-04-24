class_name State, "res://addons/uml_state_machine/icons/state.svg"
extends StateBase
tool

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["state"]) + ._get_meta_tags()

func _get_configuration_warning() -> String:
	var parent_configuration_warning = ._get_configuration_warning()
	if not parent_configuration_warning.empty():
		return parent_configuration_warning

	var parent = get_parent()
	if not parent.has_meta("stateful"):
		return "State nodes must be parented to a State, Root or Region node"

	return ""

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "State",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		}
	] + ._get_property_list_internal()

func bubble_event(event_type: int, args: Array) -> void:
	var stateful_ancestor = UMLStateMachineUtil.get_stateful_ancestor(self)
	if stateful_ancestor:
		stateful_ancestor.handle_event(event_type, args)
