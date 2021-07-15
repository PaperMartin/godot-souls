extends Node

export var StateMachine : NodePath
export var Motor : NodePath

onready var statemachine : Node = get_node(StateMachine)
onready var motor : CharacterMotor = get_node(Motor)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	#print_debug(statemachine.get_current())
	pass

func _physics_process(delta):
	statemachine.set_param("IsGrounded", motor.is_grounded())
	pass

func animation_end_trigger(var anim_name : String):
	statemachine.set_trigger("animation_end_" + anim_name)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
