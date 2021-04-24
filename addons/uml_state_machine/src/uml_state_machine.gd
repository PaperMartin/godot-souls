class_name UMLStateMachineBase
extends Node
tool

var debug_print := false
var debug_break := false

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["uml_state_machine"])

func _get_property_list() -> Array:
	return _get_property_list_internal()

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "debug",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_GROUP
		},
		{
			"name": "debug_print",
			"type": TYPE_BOOL
		},
		{
			"name": "debug_break",
			"type": TYPE_BOOL
		},
	]

func _ready() -> void:
	for tag in _get_meta_tags():
		set_meta(tag, true)

func initialize() -> void:
	for child in get_children():
		child.initialize()

func evaluate(args: Array = []) -> bool:
	assert(not debug_break)
	return false
