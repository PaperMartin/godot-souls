extends Spatial

export var MouseSensitivity : Vector2 = Vector2(1,1)
export var ControllerSensitivity : Vector2 = Vector2(1,1)
export var MinMaxVerticalRotation : Vector2 = Vector2(-89,89)
export var FollowSpeed : float = 4
export var Body : NodePath

var controller_input : Vector2
var mouse_input : Vector2

var cam_rotation : Vector2
var body : Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	body = get_node(Body)
	set_as_toplevel(true)
	pass # Replace with function body.


func _process(delta):
	translation = lerp(translation,body.global_transform.origin, 0.5 * delta * FollowSpeed)
	_update_controller_input()
	_update_input()
	_update_rotation()
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative * MouseSensitivity

func _update_controller_input():
	controller_input.x = Input.get_action_strength("camera_right") - Input.get_action_strength("camera_left")
	controller_input.y = Input.get_action_strength("camera_down") - Input.get_action_strength("camera_up")
	controller_input = controller_input * ControllerSensitivity

func _update_input():
	cam_rotation += mouse_input
	cam_rotation += controller_input
	cam_rotation.y = clamp(cam_rotation.y, MinMaxVerticalRotation.x, MinMaxVerticalRotation.y)
	mouse_input = Vector2.ZERO
	controller_input = Vector2.ZERO
	

func _update_rotation():
	rotation_degrees.x = cam_rotation.y
	rotation_degrees.y = -cam_rotation.x
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
