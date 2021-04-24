class_name EventBase
extends UMLStateMachineBase
tool

var type = UMLStateMachineEnums.EventType.Entry setget set_type
var custom_event: int setget set_custom_event
var consume_event: bool = false

var _custom_event_name: String

func set_type(new_type: int) -> void:
	if type != new_type:
		type = new_type

	update_name()

func set_custom_event(new_custom_event: int) -> void:
	if custom_event != new_custom_event:
		custom_event = new_custom_event

		update_custom_event_name()
		update_name()
		update_configuration_warning()

func update_name() -> void:
	name = get_name()

func get_name() -> String:
	if type == UMLStateMachineEnums.EventType.Custom and not _custom_event_name.empty():
			return _custom_event_name

	return UMLStateMachineEnums.EventType.keys()[type]

func update_custom_event() -> void:
	custom_event = UMLStateMachineUtil.get_custom_event_list(self).find(_custom_event_name)

func update_custom_event_name() -> void:
	var custom_event_names = UMLStateMachineUtil.get_custom_event_list(self)
	if custom_event >= 1 and custom_event <= custom_event_names.size():
		_custom_event_name = custom_event_names[custom_event]
	else:
		_custom_event_name = ""

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["eventful"])

func _get_configuration_warning() -> String:
	if not get_parent() as Root and not get_parent() as Region and not get_parent() as State:
		return "Eventful nodes must be children of Root, Region, or State"

	if type == UMLStateMachineEnums.EventType.Custom and custom_event <= 0:
		return "Custom event not set"

	return ""

func _get_property_list_internal() -> Array:
	var property_list := []

	property_list.append({
		"name": "type",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": PoolStringArray(UMLStateMachineEnums.EventType.keys()).join(",")
	})

	match type:
		UMLStateMachineEnums.EventType.Custom:
			property_list.append({
				"name": "custom_event",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": PoolStringArray(UMLStateMachineUtil.get_custom_event_list(self)).join(',')
			})

	match type:
		UMLStateMachineEnums.EventType.Entry:
			pass
		UMLStateMachineEnums.EventType.Exit:
			pass
		_:
			property_list.append({
				"name": "consume_event",
				"type": TYPE_BOOL
			})

	property_list.append({
		"name": "_custom_event_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_NOEDITOR
	})

	return property_list + ._get_property_list_internal()

func _ready() -> void:
	._ready()

	update_custom_event()
	update_name()

func initialize() -> void:
	.initialize()

	update_custom_event()
	update_name()
