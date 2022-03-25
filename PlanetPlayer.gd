extends KinematicBody

onready var _Head : Spatial = $Head
onready var _Camera : Camera = $Head/Camera

onready var last_direction := transform.basis.z

var walkspeed := 8.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta : float) -> void:
	var body_state := PhysicsServer.body_get_direct_state(get_rid())
	
	if body_state.total_gravity.length() > 0:
		var up : Vector3 = -body_state.total_gravity.normalized()
		#find new right axis
		var right_axis := up.cross(last_direction).normalized()
		#step here to get new forward direction
		var forward_axis : Vector3 = right_axis.cross(up)
		#create new rotation basis from axes
		var rotation_basis := Basis(right_axis, up, forward_axis).orthonormalized()
		
		#interpolate to new rotation basis
		transform.basis = transform.basis.get_rotation_quat().slerp(rotation_basis, delta * 20)
		last_direction = transform.basis.z
	
	#take player input
	var input = Input.get_vector("left", "right", "forward", "backward")
	#map player input to new movement plane
	var trans = _Head.global_transform.basis.xform(Vector3(input.x, 0, input.y))
	#apply movement
	move_and_slide(trans * walkspeed + body_state.total_gravity)

#camera controls
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		_Head.rotation_degrees.y -= event.relative.x * 0.1
		_Camera.rotation_degrees.x -= event.relative.y * 0.1
