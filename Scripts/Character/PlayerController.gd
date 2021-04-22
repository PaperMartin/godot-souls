extends Node

class_name PlayerController

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var acceleration : float = 1
export var Motor : NodePath

var _motor : CharacterMotor
var _move_input : Vector2 = Vector2.ZERO
var _input_velocity : Vector2 = Vector2.ZERO
var _is_sprinting : bool = false
const FLOAT_EPSILON = 0.05


# Called when the node enters the scene tree for the first time.
func _ready():
	_motor = get_node(Motor)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_refresh_input(delta)
	_update_motor_input(delta)

func _refresh_input(delta):
	_move_input.y = 0
	_move_input.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	
	_move_input.x = 0
	_move_input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	
	if Input.is_action_pressed("sprint"):
		_is_sprinting = true
	else:
		_is_sprinting = false
	pass

func _update_motor_input(delta):
	_motor.raw_movement_input = _move_input
	_motor.sprint_input = _is_sprinting
