extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var StateName : String

signal enter
signal exit
signal update(delta)

func _ready():
	var statemachine : Node = get_parent()
	statemachine.connect("transited",self,"on_enter")
	statemachine.connect("transited",self,"on_exit")
	statemachine.connect("updated",self,"on_update")

# Called when the node enters the scene tree for the first time.
func on_enter(var _from : String, var to : String):
	if to == StateName:
		#print_debug("entering " + StateName)
		emit_signal("enter")

func on_exit(var from : String, var _to : String):
	if from == StateName:
		#print_debug("exiting " + StateName)
		emit_signal("exit")

func on_update(var state : String, var delta : float):
	if state == StateName:
		emit_signal("update",delta)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
