extends KinematicBody

onready var _Head : Spatial = $Head
onready var _Camera : Camera = $Head/Camera

onready var last_direction := transform.basis.z

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta : float) -> void:
	var body_state := PhysicsServer.body_get_direct_state(get_rid())
	
	if (body_state.total_gravity.length() > 0):
		var up : Vector3 = -body_state.total_gravity.normalized()
		var left_axis := up.cross(last_direction)
		var rotation_basis := Basis(left_axis, up, last_direction).orthonormalized()
		transform.basis = transform.basis.get_rotation_quat().slerp(rotation_basis, delta * 10)
		last_direction = transform.basis.z
	
	
	var input = Input.get_vector("left", "right", "forward", "backward")
	var trans = _Head.global_transform.basis.xform(Vector3(input.x, 0, input.y))
	move_and_slide(trans * 10 + body_state.total_gravity)
	

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		_Head.rotation_degrees.y -= event.relative.x * 0.1
		_Camera.rotation_degrees.x -= event.relative.y * 0.1
