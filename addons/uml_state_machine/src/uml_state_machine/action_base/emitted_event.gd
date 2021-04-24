class_name EmittedEvent, "res://addons/uml_state_machine/icons/emitted_event.svg"
extends ActionBase
tool

var event: int setget set_event

var _event_name: String

func set_event(new_event: int) -> void:
	if event != new_event:
		event = new_event

		update_event_name()
		update_name()

		update_configuration_warning()

func update_event() -> void:
	event = UMLStateMachineUtil.get_custom_event_list(self).find(_event_name)

func update_event_name() -> void:
	var event_names = UMLStateMachineUtil.get_custom_event_list(self)
	if event >= 1 and event <= event_names.size():
		_event_name = event_names[event]
	else:
		_event_name = ""

func update_name() -> void:
	name = "EmittedEvent" if _event_name.empty() else _event_name

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["emitted_event"])

func _get_configuration_warning() -> String:
	var parent = get_parent()
	if not parent.has_meta("event") and not parent.has_meta("guard") and not parent.has_meta("transition"):
		return "EmittedEvent nodes must be parented to an Event, Guard or Transition node"

	if event <= 0:
		return "Event not set"

	return ""

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "EmittedEvent",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		},
		{
			"name": "event",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(UMLStateMachineUtil.get_custom_event_list(self)).join(",")
		},
		{
			"name": "_event_name",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_NOEDITOR
		}
	] + ._get_property_list_internal()

func _ready() -> void:
	._ready()

	if Engine.is_editor_hint():
		update_event()

func initialize() -> void:
	.initialize()

	update_event()

func get_name() -> String:
	return "EmittedEvent"

func evaluate(args: Array = []) -> bool:
	.evaluate(args)

	var candidate = self
	var root_ancestor = null
	while true:
		var candidate_ancestor = UMLStateMachineUtil.get_root_ancestor(candidate)
		if candidate_ancestor:
			candidate = candidate_ancestor
			root_ancestor = candidate_ancestor
		else:
			break

	if not root_ancestor:
		return false

	root_ancestor.buffer_event(UMLStateMachineEnums.EventType.Custom, [_event_name])

	return false

