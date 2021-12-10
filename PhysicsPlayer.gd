extends RigidBody

onready var _Head : Spatial = $Head
onready var _Camera : Camera = $Head/Camera
onready var Raycast : RayCast = $RayCast

var max_leg_force : float = 160.0
var damping : float = 1.0
var overcome_damping : float = damping * mass
var max_running_speed : float = 3.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#damping function
#old
#m_linearVelocity *= btMax((btScalar(1.0) - timeStep * m_linearDamping), btScalar(0.0));
#new
#m_linearVelocity *= btPow(btScalar(1) - m_linearDamping, timeStep);
#E:\Godot\godot\thirdparty\bullet\BulletDynamics\Dynamics\btRigidBody.cpp

func _physics_process(delta : float) -> void:
	var input = Input.get_vector("left", "right", "forward", "backward")
	var transformed = _Head.global_transform.basis.xform(Vector3(input.x, 0, input.y))
	#if on ground
	#might want to change this to a capsule shape
	if Raycast.is_colliding():
		#prevents bobbing up and down
		legs_force(delta)
		ground_movement(transformed, delta)
	else:
		#when not on ground, don't damp, it messes with other physics
		air_movement(transformed, delta)

#keeps the player hovering above the ground
func legs_force(delta : float) -> void:
	#keeps verical hight where it should be
	var distance = (global_transform.origin + global_transform.basis.y * -0.3).distance_to(Raycast.get_collision_point())
	var force : float = range_lerp(distance, 0, 0.7, max_leg_force, 0) - linear_velocity.y * 50
	apply_impulse(global_transform.basis.y * -1, global_transform.basis.y * force * 9.8 * delta)
	
	#keep upright
	
	

func ground_movement(direction : Vector3, delta : float) -> void:
	
	var desired_velocity := direction * max_running_speed
	var force := (desired_velocity - linear_velocity) * max_leg_force
	print(linear_velocity)
	
	#full force when standing still or slowing down
	apply_central_impulse(force * delta)

func air_movement(direction : Vector3, delta : float) -> void:
	pass

static func bias(x : float, bias : float) -> float:
	var k : float = pow(1 - bias, 3)
	return (x * k) / (x * k - x + 1)

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		_Head.rotation_degrees.y -= event.relative.x * 0.1
		_Camera.rotation_degrees.x -= event.relative.y * 0.1
