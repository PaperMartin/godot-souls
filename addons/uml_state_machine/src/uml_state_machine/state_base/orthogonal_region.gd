class_name Region, "res://addons/uml_state_machine/icons/orthogonal_region.svg"
extends StateBase
tool

func is_active() -> bool:
	var stateful_parent = UMLStateMachineUtil.get_stateful_ancestor(self)
	return stateful_parent.is_active()

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["orthogonal_region"]) + ._get_meta_tags()

func _get_configuration_warning() -> String:
	var parent_warning = ._get_configuration_warning()
	if not parent_warning.empty():
		return parent_warning

	var parent = get_parent()
	if not parent.has_meta("stateful"):
		return "Region nodes must be parented to a Root, Region or State node"

	return ""

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "Region",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		}
	] + ._get_property_list_internal()
