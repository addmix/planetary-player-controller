extends RigidBody

onready var _Head : Spatial = $Head
onready var _Camera : Camera = $Head/Camera
onready var Raycast : RayCast = $RayCast

var max_leg_force : float = 100.0
var damping : float = 10.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta : float) -> void:
	#if on ground
	#might want to change this to a capsule shape
	if Raycast.is_colliding():
		var distance = (global_transform.origin + global_transform.basis.y * -0.6).distance_to(Raycast.get_collision_point())
		var force : float = range_lerp(distance, 0, 0.4, 160, 0)
		apply_impulse(global_transform.basis.y * -1, global_transform.basis.y * force * 9.8 * delta)
		#prevents bobbing up and down
		linear_damp = damping
	else:
		#when not on ground, don't damp, it messes with other physics
		linear_damp = -1.0

func _integrate_forces(state : PhysicsDirectBodyState) -> void:
	pass

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		_Head.rotation_degrees.y -= event.relative.x * 0.1
		_Camera.rotation_degrees.x -= event.relative.y * 0.1
