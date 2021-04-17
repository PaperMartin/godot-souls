extends Spatial

export var Sensitivity : Vector2 = Vector2(1,1)
export var MinMaxVerticalRotation : Vector2 = Vector2(-89,89)
export var FollowSpeed : float = 4
export var Body : NodePath

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
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		cam_rotation += event.relative * Sensitivity
		cam_rotation.y = clamp(cam_rotation.y, MinMaxVerticalRotation.x, MinMaxVerticalRotation.y)
		_update_rotation()

func _update_rotation():
	rotation_degrees.x = cam_rotation.y
	rotation_degrees.y = -cam_rotation.x
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
