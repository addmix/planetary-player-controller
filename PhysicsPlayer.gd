extends RigidDynamicBody3D

@onready var _Head : Node3D = $Head
@onready var _Camera : Camera3D = $Head/Camera
@onready var Raycast : RayCast3D = $RayCast

@onready var last_direction := global_transform.basis.z

@export var max_leg_force : float = 160.0
@export var jump_force : float = 200.0
@export var damp : float = 10.0
@export var overcome_damping : float = damp * mass
@export var max_running_speed : float = 3.0
@export var rotation_force : float = 500.0
@export var rotation_damp : float = 50.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _integrate_forces(state : PhysicsDirectBodyState3D) -> void:
	var input = Input.get_vector("left", "right", "forward", "backward")
	var delta : float = get_physics_process_delta_time()
	
	var transformed = _Head.global_transform.basis * Vector3(input.x, 0, input.y)
	#if on ground
	#might want to change this to a capsule shape
	if Raycast.is_colliding():
		#prevents bobbing up and down
		legs_force(delta, state)
		movement_damping(delta, state)
		ground_movement(transformed, delta)
		keep_upright(delta, state)
		rotation_damping(delta, state)
		
	else:
		#when not on ground, don't damp, it messes with other physics
		air_movement(transformed, delta)
	
	
	if (state.total_gravity.length() > 0):
		pass
	
	last_direction = global_transform.basis.z

#keeps the player hovering above the ground
func legs_force(delta : float, body_state : PhysicsDirectBodyState3D) -> void:
	#keeps verical hight where it should be
	var distance = (global_transform.origin + global_transform.basis.y * -0.3).distance_to(Raycast.get_collision_point())
	#allows crouching
	var leg_height : float = (0.7 * float(!Input.is_action_pressed("crouch"))) + (0.3 * float(Input.is_action_pressed("crouch")))
	#basically makes jumping the same as stiff-legging
	var min_force : float = jump_force * float(Input.is_action_pressed("jump"))
	var force : float = clamp(range_lerp(distance, 0, leg_height, max_leg_force, min_force), 0, max_leg_force)
	apply_force(global_transform.basis.y * -1.0, global_transform.basis.y * force * body_state.total_gravity.length())

func movement_damping(delta : float, body_state : PhysicsDirectBodyState3D) -> void:
	#transform to local y axis
	var local_y_velocity : float = (global_transform.basis.inverse() * linear_velocity).y
	var damp_force := -local_y_velocity * damp
	
	apply_force(global_transform.basis.y * -1, global_transform.basis.y * damp_force * body_state.total_gravity.length())

func keep_upright(delta : float, body_state : PhysicsDirectBodyState3D) -> void:
	var up : Vector3 = -body_state.total_gravity.normalized()
	
	#prevents 0 gravity from causing divide by 0 errors
	up += global_transform.basis.y * float(up == Vector3.ZERO)
	
	var right_axis := up.cross(last_direction)
	#why did 4.0 make it necessary for these to be negative?
	var desired_orientation := Basis(right_axis, -up, -last_direction).orthonormalized()
	
	var force : Quaternion = MathUtils.quat_to_axis_angle((desired_orientation * (global_transform.basis.inverse())).get_rotation_quaternion())
	apply_torque(Vector3(force.x, force.y, force.z) * force.w * rotation_force)

func rotation_damping(delta : float, _body_state : PhysicsDirectBodyState3D) -> void:
	apply_torque(-angular_velocity * rotation_damp)

#direction is already in global space
func ground_movement(direction : Vector3, delta : float) -> void:
	var desired_velocity := direction * max_running_speed
	var force := (desired_velocity - linear_velocity) * max_leg_force
	
	#full force when standing still or slowing down
	apply_central_force(force)

func air_movement(_direction : Vector3, _delta : float) -> void:
	pass

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		_Head.rotation.y -= deg2rad(event.relative.x * 0.1)
		_Camera.rotation.x -= deg2rad(event.relative.y * 0.1)
