extends Spatial

export var Body : NodePath
export var Motor : NodePath

onready var body : Spatial = get_node(Body)
onready var motor : CharacterMotor = get_node(Motor)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.



func _process(delta):
	translation = body.translation
	look_at(translation + motor.target_direction,Vector3.UP)
	pass
