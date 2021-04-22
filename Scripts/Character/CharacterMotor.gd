extends Node

class_name CharacterMotor

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var Gravity : float = 10
export var RotationSpeed : float = 4
export var AccelerationSpeed : float = 2
export var Body : NodePath
export var AnimTree : NodePath
export var MovementAxis : NodePath

onready var _anim_tree : AnimationTree = get_node(AnimTree)
onready var _body : KinematicBody = get_node(Body)
onready var _movementaxis : Spatial = get_node(MovementAxis)

var sprint_input : bool = false
var raw_movement_input : Vector2
var current_direction : Vector3 = Vector3.ZERO
var target_direction : Vector3
var currentAcceleration : float
var currentGravity : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if raw_movement_input.length() > 0:
		target_direction = _get_target_direction(raw_movement_input)
	_update_acceleration(delta)
	_calculate_gravity(delta)
	_turn_character(target_direction,delta)
	_calculate_movement(delta)

func _update_acceleration(delta):
	if raw_movement_input.normalized().length() > 0:
		currentAcceleration += AccelerationSpeed * delta
	else:
		currentAcceleration -= AccelerationSpeed * delta
	
	if sprint_input:
		currentAcceleration = clamp(currentAcceleration,0,1)
	else:
		currentAcceleration = clamp(currentAcceleration,0,0.5)

func _calculate_movement(delta):
	
	
	_anim_tree.set_movement_speed(currentAcceleration)
	
	var rootmotion : Transform = _get_root_motion()
	var velocity : Vector3 = rootmotion.origin
	
	velocity.y += currentGravity * delta
	if velocity.y >= 0:
		velocity.y -= delta
	
# warning-ignore:return_value_discarded
	_body.move_and_slide_with_snap(velocity / delta, Vector3(0,-0.1,0),Vector3(0,1,0), true)

func _get_root_motion() -> Transform:
	var rootmotion : Transform = _anim_tree.get_root_motion_transform().rotated(Vector3(0,1,0),_body.rotation.y)
	return rootmotion

func _get_target_direction(input : Vector2) -> Vector3:
	
	var ForwardDirection : Vector3 = _movementaxis.global_transform.basis.z
	var LeftDirection : Vector3 = _movementaxis.global_transform.basis.x
	
	var ProjectedForwardDirection : Vector3 = ForwardDirection.slide(Vector3.UP)
	var ProjectedLeftDirection = LeftDirection.slide(Vector3.UP)
	
	var targetDirection : Vector3 = Vector3.ZERO
	
	targetDirection += ProjectedForwardDirection * input.y
	targetDirection += ProjectedLeftDirection * input.x
	
	targetDirection = targetDirection.normalized()
	
	return targetDirection

func _calculate_gravity(delta):
	if _body.is_on_floor():
		currentGravity = 0
	else:
		currentGravity -= delta * Gravity

func _turn_character(target_direction : Vector3, delta : float):
	current_direction = lerp(current_direction, target_direction, delta * RotationSpeed)
	var target : Vector3 = current_direction + _body.translation
	if current_direction.length() != 0:
		_body.look_at(target,Vector3.UP)
