extends Node

class_name PlayerController

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var acceleration : float = 1
export var AnimTree : NodePath
export var Motor : NodePath

var _anim_tree : AnimationTree
var _motor : CharacterMotor
var _move_input : Vector2 = Vector2.ZERO
var _input_velocity : Vector2 = Vector2.ZERO
var _is_sprinting : bool = false
const FLOAT_EPSILON = 0.05


# Called when the node enters the scene tree for the first time.
func _ready():
	_anim_tree = get_node(AnimTree)
	_motor = get_node(Motor)
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action("move_backward") or event.is_action("move_forward"):
		_move_input.y = event.get_action_strength("move_forward") - event.get_action_strength("move_backward")
	
	if event.is_action("move_left") or event.is_action("move_right"):
		_move_input.x = event.get_action_strength("move_left") - event.get_action_strength("move_right")
	
	if event.is_action_pressed("sprint"):
		_is_sprinting = true
	if event.is_action_released("sprint"):
		_is_sprinting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_input(delta)
	_update_movement_input(delta)

func _update_input(delta):
	_move_input.y = 0
	_move_input.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	
	_move_input.x = 0
	_move_input.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	
	if Input.is_action_pressed("sprint"):
		_is_sprinting = true
	else:
		_is_sprinting = false
	pass

func _update_movement_input(delta):
	_motor.movement_input = _move_input
