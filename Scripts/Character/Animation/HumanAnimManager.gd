extends AnimationTree


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var BodyPath : NodePath

onready var _body : KinematicBody = get_node(BodyPath) as KinematicBody

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_movement_speed(var speed : float):
	self["parameters/StateMachine/idle/forward_movement/blend_position"] = speed
	pass

func _physics_process(delta):
	
	if _body.is_on_floor() == true:
		print_debug("is not falling")
		self["parameters/StateMachine/conditions/is_falling"] = false;
		self["parameters/StateMachine/conditions/is_not_falling"] = true;
	else:
		print_debug("is falling")
		self["parameters/StateMachine/conditions/is_falling"] = true;
		self["parameters/StateMachine/conditions/is_not_falling"] = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
