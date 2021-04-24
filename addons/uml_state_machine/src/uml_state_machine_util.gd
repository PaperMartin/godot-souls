class_name UMLStateMachineUtil

static func get_root_ancestor(candidate: UMLStateMachineBase) -> UMLStateMachineBase:
	while true:
		var parent = candidate.get_parent() as UMLStateMachineBase
		if not parent:
			break
		if parent.has_meta("root"):
			return parent
		candidate = parent
	return null

static func get_event_ancestor(candidate: UMLStateMachineBase) -> UMLStateMachineBase:
	while true:
		var parent = candidate.get_parent() as UMLStateMachineBase
		if not parent:
			break
		if parent.has_meta("event"):
			return parent
		candidate = parent

	return null

static func get_guard_ancestor(candidate: UMLStateMachineBase) -> UMLStateMachineBase:
	while true:
		var parent = candidate.get_parent() as UMLStateMachineBase
		if not parent:
			break
		if parent.has_meta("guard"):
			return parent
		candidate = parent

	return null

static func get_stateful_ancestor(candidate: UMLStateMachineBase) -> UMLStateMachineBase:
	while true:
		var parent = candidate.get_parent() as UMLStateMachineBase
		if not parent:
			break
		if parent.has_meta("stateful"):
			return parent
		candidate = parent

	return null


static func get_root_descendants(candidate: UMLStateMachineBase) -> Array:
	#print_debug("get_root_descendants(%s)" % [candidate])
	#print_debug("Candidate name %s" % [candidate.get_name()])
	#print_debug("Candidate children: %s" % [candidate.get_children()])
	var root_descendants := []

	if candidate:
		for child in candidate.get_children():
			#print_debug("Candidate child: %s" % [child])
			#print_debug("Candidate child script: %s" % [child.get_script()])
			if child.has_meta("root"):
				root_descendants.append(child)
			root_descendants += get_root_descendants(child)
	return root_descendants


static func get_stateful_descendants(candidate: UMLStateMachineBase) -> Array:
	var stateful_descendants := []
	for child in candidate.get_children():
		if child.has_meta("stateful"):
			stateful_descendants.append(child)
		stateful_descendants += get_stateful_descendants(child)
	return stateful_descendants


static func get_leaf_stateful_descendants(candidate: UMLStateMachineBase) -> Array:
	var leaf_stateful_descendants := []
	var leaf = true
	for child in candidate.get_children():
		if child.has_meta("state"):
			leaf = false
	if candidate.has_meta("stateful") and leaf:
		leaf_stateful_descendants.append(candidate)

	for child in candidate.get_children():
		leaf_stateful_descendants += get_leaf_stateful_descendants(child)

	return leaf_stateful_descendants


static func get_root_target_instance(candidate: UMLStateMachineBase) -> Node:
	var root = get_root_ancestor(candidate)
	if not root:
		return null
	return root.get_target_instance()


static func get_root_target_script_properties(candidate: UMLStateMachineBase) -> Array:
	var root = get_root_ancestor(candidate)
	if not root:
		return []
	return root.get_target_script_property_list()

static func get_property_names(candidate: UMLStateMachineBase) -> Array:
	var property_names := ["[None]"]
	for script_property in get_root_target_script_properties(candidate):
		property_names.append(script_property.name)
	return property_names

static func get_properties_enum_string(candidate: UMLStateMachineBase) -> String:
	var property_names = get_property_names(candidate)
	return PoolStringArray(property_names).join(',')


static func get_root_target_script_methods(candidate: UMLStateMachineBase) -> Array:
	var root = get_root_ancestor(candidate)
	if not root:
		return []
	return root.get_target_script_method_list()

static func get_methods_enum_string(candidate: UMLStateMachineBase) -> String:
	var method_names = get_method_names(candidate)
	return PoolStringArray(method_names).join(',')

static func get_method_names(candidate: UMLStateMachineBase) -> Array:
	var method_names := ["[None]"]
	for script_method in get_root_target_script_methods(candidate):
		method_names.append(script_method.name)
	return method_names


static func get_input_action_names() -> Array:
	var input_action_names := ["[None]"]
	InputMap.load_from_globals()
	var actions = InputMap.get_actions()
	for action in actions:
		input_action_names.append(action)
	input_action_names.sort()
	return input_action_names

static func get_target_script_method(candidate: UMLStateMachineBase, method_name: String) -> Dictionary:
	var target_script_methods = get_root_target_script_methods(candidate)
	for script_method in target_script_methods:
		if script_method.name == method_name:
			return script_method
	return {}


static func get_target_script_property(candidate: UMLStateMachineBase, property_name: String) -> Dictionary:
	var target_script_properties = get_root_target_script_properties(candidate)
	for script_property in target_script_properties:
		if script_property.name == property_name:
			return script_property
	return {}

static func get_type_default(type: int):
	print_debug("getting type default for type %s" % [type])
	match type:
		TYPE_BOOL:
			return false
		TYPE_INT:
			return 0
		TYPE_REAL:
			return 0.0
		TYPE_STRING:
			return ""
		TYPE_VECTOR2:
			return Vector2()
		TYPE_RECT2:
			return Rect2()
		TYPE_VECTOR3:
			return Vector3()
		TYPE_TRANSFORM2D:
			return Transform2D()
		TYPE_PLANE:
			return Plane()
		TYPE_QUAT:
			return Quat()
		TYPE_AABB:
			return AABB()
		TYPE_BASIS:
			return Basis()
		TYPE_TRANSFORM:
			return Transform()
		TYPE_COLOR:
			return Color()
		TYPE_NODE_PATH:
			return NodePath()
		TYPE_RID:
			return RID()
		TYPE_OBJECT:
			return Object()
		TYPE_DICTIONARY:
			return {}
		TYPE_ARRAY:
			return []
		TYPE_RAW_ARRAY:
			return PoolByteArray()
		TYPE_INT_ARRAY:
			return PoolIntArray()
		TYPE_REAL_ARRAY:
			return PoolRealArray()
		TYPE_STRING_ARRAY:
			return PoolStringArray()
		TYPE_VECTOR2_ARRAY:
			return PoolVector2Array()
		TYPE_VECTOR3_ARRAY:
			return PoolVector3Array()
		TYPE_COLOR_ARRAY:
			return PoolColorArray()
	return null

static func gather_children_top_down(candidate: UMLStateMachineBase) -> Array:
	var gathered := [candidate]
	for child in candidate.get_children():
		gathered += gather_children_top_down(child)
	return gathered

static func gather_children_bottom_up(candidate: UMLStateMachineBase) -> Array:
	var top_down = gather_children_top_down(candidate)
	var bottom_up := []
	for child in top_down:
		bottom_up.push_front(child)
	return bottom_up

static func get_root_state_child_list(candidate: UMLStateMachineBase) -> Array:
	var root_ancestor = get_root_ancestor(candidate)
	if root_ancestor:
		return root_ancestor.get_state_child_list()
	return []

static func get_child_state_name_list(candidate: UMLStateMachineBase) -> PoolStringArray:
	var state_list = get_root_state_child_list(candidate)
	var state_list_string_arr := PoolStringArray(["[None]"])
	for state_path in state_list:
		var path = ""
		for i in range(0, state_path.get_name_count()):
			path += state_path.get_name(i)
			if i < state_path.get_name_count() - 1:
				path += "/"
		state_list_string_arr.append(path)
	return state_list_string_arr

static func get_root_state_parent_list(candidate: UMLStateMachineBase) -> Array:
	var root_ancestor = get_root_ancestor(candidate)
	if root_ancestor:
		return root_ancestor.get_state_parent_list()
	return []

static func get_parent_state_name_list(candidate: UMLStateMachineBase) -> PoolStringArray:
	var state_list = get_root_state_parent_list(candidate)
	var state_list_string_arr := PoolStringArray(["[None]"])
	for state_path in state_list:
		var path = ""
		for i in range(0, state_path.get_name_count()):
			path += state_path.get_name(i)
			if i < state_path.get_name_count() - 1:
				path += "/"
		state_list_string_arr.append(path)
	return state_list_string_arr

static func get_custom_event_list(candidate: UMLStateMachineBase) -> Array:
	var root_ancestor = get_root_ancestor(candidate)
	if not root_ancestor:
		return []

	var custom_event_list := ["[None]"]
	var ancestor_events = Array(root_ancestor.get_custom_event_list())
	custom_event_list += ancestor_events
	return custom_event_list
