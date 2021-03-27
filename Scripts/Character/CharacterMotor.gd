extends Node

class_name CharacterMotor

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var RotationSpeed : float
export var AnimTree : NodePath

var animTree : AnimationTree
var body : KinematicBody

var rotation_input : float

# Called when the node enters the scene tree for the first time.
func _ready():
	animTree = get_node(AnimTree)
	body = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_turn_character(delta)
	_calculate_movement(delta)

func _calculate_movement(delta):
	var velocity : Transform = animTree.get_root_motion_transform().rotated(Vector3(0,1,0),body.rotation.y)
	body.move_and_slide(velocity.origin / delta,Vector3(0,1,0))

func _turn_character(delta):
	body.rotation.y += rotation_input * RotationSpeed * delta
