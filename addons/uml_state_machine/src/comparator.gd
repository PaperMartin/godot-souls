class_name Comparator
extends Resource
tool

const comparator_type_name_map := {
	TYPE_NIL: "null_comparator",
	TYPE_BOOL: "bool_comparator",
	TYPE_INT: "int_comparator",
	TYPE_REAL: "float_comparator",
	TYPE_STRING: "string_comparator",
	TYPE_VECTOR2: "vector2_comparator",
	TYPE_RECT2: "rect2_comparator",
	TYPE_VECTOR3: "vector3_comparator",
	TYPE_TRANSFORM2D: "transform2d_comparator",
	TYPE_PLANE: "plane_comparator",
	TYPE_QUAT: "quat_comparator",
	TYPE_AABB: "aabb_comparator",
	TYPE_BASIS: "basis_comparator",
	TYPE_TRANSFORM: "transform_comparator",
	TYPE_COLOR: "color_comparator",
	TYPE_NODE_PATH: "node_path_comparator",
	TYPE_OBJECT: "object_comparator",
	TYPE_DICTIONARY: "dictionary_comparator",
	TYPE_ARRAY: "array_comparator",
	TYPE_RAW_ARRAY: "byte_array_comparator",
	TYPE_INT_ARRAY: "int_array_comparator",
	TYPE_REAL_ARRAY: "real_array_comparator",
	TYPE_STRING_ARRAY: "string_array_comparator",
	TYPE_VECTOR2_ARRAY: "vector2_array_comparator",
	TYPE_VECTOR3_ARRAY: "vector3_array_comparator",
	TYPE_COLOR_ARRAY: "color_array_comparator",
}

var type: int setget set_type
var operator: int

var null_comparator = null
var bool_comparator := false
var int_comparator := 0
var float_comparator := 0.0
var string_comparator := ""
var vector2_comparator := Vector2()
var rect2_comparator := Rect2()
var vector3_comparator := Vector3()
var transform2d_comparator := Transform2D()
var plane_comparator := Plane()
var quat_comparator := Quat()
var aabb_comparator := AABB()
var basis_comparator := Basis()
var transform_comparator := Transform()
var color_comparator := Color()
var node_path_comparator := NodePath()
var object_comparator: Object = Object()
var dictionary_comparator := {}
var array_comparator := []
var byte_array_comparator := PoolByteArray()
var int_array_comparator := PoolIntArray()
var real_array_comparator := PoolRealArray()
var string_array_comparator := PoolStringArray()
var vector2_array_comparator := PoolVector2Array()
var vector3_array_comparator := PoolVector3Array()
var color_array_comparator := PoolColorArray()

func set_type(new_type: int) -> void:
	if type != new_type:
		type = new_type

		property_list_changed_notify()

func get_value():
	match type:
		TYPE_NIL:
			return null_comparator
		TYPE_BOOL:
			return bool_comparator
		TYPE_INT:
			return int_comparator
		TYPE_REAL:
			return float_comparator
		TYPE_STRING:
			return string_comparator
		TYPE_VECTOR2:
			return vector2_comparator
		TYPE_RECT2:
			return rect2_comparator
		TYPE_VECTOR3:
			return vector3_comparator
		TYPE_TRANSFORM2D:
			return transform2d_comparator
		TYPE_PLANE:
			return plane_comparator
		TYPE_QUAT:
			return quat_comparator
		TYPE_AABB:
			return aabb_comparator
		TYPE_BASIS:
			return basis_comparator
		TYPE_TRANSFORM:
			return transform_comparator
		TYPE_COLOR:
			return color_comparator
		TYPE_NODE_PATH:
			return node_path_comparator
		TYPE_OBJECT:
			return object_comparator
		TYPE_DICTIONARY:
			return dictionary_comparator
		TYPE_ARRAY:
			return array_comparator
		TYPE_RAW_ARRAY:
			return byte_array_comparator
		TYPE_INT_ARRAY:
			return int_array_comparator
		TYPE_REAL_ARRAY:
			return real_array_comparator
		TYPE_STRING_ARRAY:
			return string_array_comparator
		TYPE_VECTOR2_ARRAY:
			return vector2_array_comparator
		TYPE_VECTOR3_ARRAY:
			return vector3_array_comparator
		TYPE_COLOR_ARRAY:
			return color_array_comparator

func _get_property_list() -> Array:
	return [
		{
			"name": "type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(comparator_type_name_map.keys()).join(','),
			"usage": PROPERTY_USAGE_NOEDITOR
		},
		{
			"name": "operator",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(UMLStateMachineEnums.ComparisonOperator.keys()).join(',')
		}
	] + _get_comparator_property_dicts()

func _init() -> void:
	resource_name = "Comparator"

func _get_comparator_property_dicts() -> Array:
	var property_dicts := []
	for key in comparator_type_name_map:
		var value = comparator_type_name_map[key]
		var property_dict := {
			"name": value,
			"type": key
		}

		if key != type:
			property_dict["usage"] = PROPERTY_USAGE_NOEDITOR

		property_dicts.append(property_dict)
	return property_dicts


func evaluate(lhs) -> bool:
	var rhs = self[comparator_type_name_map[type]]

	match operator:
		UMLStateMachineEnums.ComparisonOperator.Equal:
			return lhs == rhs
		UMLStateMachineEnums.ComparisonOperator.NotEqual:
			return lhs != rhs
		UMLStateMachineEnums.ComparisonOperator.Greater:
			return lhs > rhs
		UMLStateMachineEnums.ComparisonOperator.GreaterOrEqual:
			return lhs >= rhs
		UMLStateMachineEnums.ComparisonOperator.Lesser:
			return lhs < rhs
		UMLStateMachineEnums.ComparisonOperator.LesserOrEqual:
			return lhs <= rhs
	return false
