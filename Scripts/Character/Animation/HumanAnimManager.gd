extends AnimationTree


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var BodyPath : NodePath

onready var _body : KinematicBody = get_node(BodyPath) as KinematicBody

var FallTimer : float = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_movement_speed(var speed : float):
	self["parameters/StateMachine/idle/forward_movement/blend_position"] = speed
	pass

func _physics_process(delta):
	_update_fall(delta)

func _update_fall(var delta : float):
	if _body.is_on_floor() == true:
		self["parameters/StateMachine/conditions/is_falling"] = false;
		self["parameters/StateMachine/conditions/is_not_falling"] = true;
		FallTimer = 0
	else:
		FallTimer += delta
		if FallTimer > 0.25:
			self["parameters/StateMachine/conditions/is_falling"] = true;
			self["parameters/StateMachine/conditions/is_not_falling"] = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
