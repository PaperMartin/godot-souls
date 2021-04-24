class_name DeferredEvent, "res://addons/uml_state_machine/icons/deferred_event.svg"
extends EventBase
tool

func _get_meta_tags() -> PoolStringArray:
	return PoolStringArray(["deferred_event"]) + ._get_meta_tags()

func _get_configuration_warning() -> String:
	var parent_warning = ._get_configuration_warning()
	if not parent_warning.empty():
		return parent_warning

	match type:
		UMLStateMachineEnums.EventType.InputAction:
			pass
		UMLStateMachineEnums.EventType.Custom:
			pass
		_:
			return get_type_error_message(type)

	return ""

func get_type_error_message(event_type: int) -> String:
	 return "Deferring events of type %s is unsupported" % [UMLStateMachineEnums.EventType.keys()[type]]

func get_name() -> String:
	return "Defer" + .get_name()

func _get_property_list_internal() -> Array:
	return [
		{
			"name": "DeferredEvent",
			"type": TYPE_STRING,
			"usage": PROPERTY_USAGE_CATEGORY
		}
	] + ._get_property_list_internal()

func evaluate(args: Array = []) -> bool:
	.evaluate(args)

	#var debug_print := true

	if debug_print:
		print_debug("DeferredEvent %s evaluating with args %s" % [get_name(), args])

	match type:
		UMLStateMachineEnums.EventType.Entry:
			printerr(get_type_error_message(type))
		UMLStateMachineEnums.EventType.Exit:
			printerr(get_type_error_message(type))
		UMLStateMachineEnums.EventType.Process:
			printerr(get_type_error_message(type))
		UMLStateMachineEnums.EventType.PhysicsProcess:
			printerr(get_type_error_message(type))
		_:
			var root_ancestor = UMLStateMachineUtil.get_root_ancestor(self)
			if not root_ancestor:
				return false

			var candidate = self
			var event_recipient = null
			while true:
				candidate = UMLStateMachineUtil.get_stateful_ancestor(candidate)
				if not candidate:
					break

				if candidate.has_meta("orthogonal_region") or candidate.has_meta("root"):
					event_recipient = candidate
					break

			if not event_recipient:
				return false

			event_recipient.defer_event(type, args)

	return false
