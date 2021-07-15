extends AnimationTree


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal animation_end(anim_name)
export var CoyoteTime : float = 0.1
export var BodyPath : NodePath
export var StateDict : Dictionary

onready var _body : KinematicBody = get_node(BodyPath) as KinematicBody

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func emit_animation_end(var animation : String):
	emit_signal("animation_end", animation)

func set_movement_speed(var speed : float):
	self["parameters/WalkSpeed/blend_position"] = speed
	pass

func set_state(var state : String):
	self["parameters/State/current"] = StateDict.get(state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
