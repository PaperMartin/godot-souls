extends Node

class_name CharacterMotor

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var Gravity : float = 10
export var RotationSpeed : float = 4
export var AnimTree : NodePath

var animTree : AnimationTree
var body : KinematicBody

var rotation_input : float
var currentGravity : float

# Called when the node enters the scene tree for the first time.
func _ready():
	animTree = get_node(AnimTree)
	body = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_calculate_gravity(delta)
	_turn_character(delta)
	_calculate_movement(delta)

func _calculate_movement(delta):
	var rootmotion : Transform = animTree.get_root_motion_transform().rotated(Vector3(0,1,0),body.rotation.y)
	var velocity : Vector3 = rootmotion.origin
	velocity.y -= delta * 2
	velocity.y += currentGravity * delta
	body.move_and_slide(velocity / delta,Vector3(0,1,0), true)

func _calculate_gravity(delta):
	if body.is_on_floor():
		currentGravity = 0
	else:
		currentGravity -= delta * Gravity

func _turn_character(delta):
	body.rotation.y += rotation_input * RotationSpeed * delta
