extends Spatial
class_name SpringArm3D

var parent_spring : SpringArm3D
var parent_physics_body : RigidBody

#how much z torque is transmitted to the parent spring
export var torque_transmission : float = 0.5
export var inertia_tensor := Vector3(1, 1, 1) setget set_inertia_tensor
var inverse_inertia_tensor : Vector3 = Vector3(1, 1, 1)

func set_inertia_tensor(value : Vector3) -> void:
	inertia_tensor = value
	inverse_inertia_tensor = Vector3(1, 1, 1) / inertia_tensor

var spring := Spring3D.new()
export var position : Vector3 = rotation setget set_position
export var velocity := Vector3.ZERO setget set_velocity
export var target : Vector3 = rotation setget set_target
export var damping : float = 0.5 setget set_damping
export var speed : float = 10.0 setget set_speed
export var mass : float = 1.0 setget set_mass
export var clamp_x : bool = false setget set_clamp_x
export var clamp_y : bool = false setget set_clamp_y
export var clamp_z : bool = false setget set_clamp_z
export var _max := Vector3(0, 0, 0) setget set_max
export var _min := Vector3(0, 0, 0) setget set_min

func set_position(value : Vector3) -> void:
	position = value
	update_spring()
func set_velocity(value : Vector3) -> void:
	velocity = value
	update_spring()
func set_target(value : Vector3) -> void:
	target = value
	update_spring()
func set_damping(value : float) -> void:
	damping = value
	update_spring()
func set_speed(value : float) -> void:
	update_spring()
	speed = value
func set_mass(value : float) -> void:
	mass = value
	update_spring()
func set_clamp_x(value : bool) -> void:
	clamp_x = value
	update_spring()
func set_clamp_y(value : bool) -> void:
	clamp_y = value
	update_spring()
func set_clamp_z(value : bool) -> void:
	clamp_z = value
	update_spring()
func set_max(value : Vector3) -> void:
	_max = value
	update_spring()
func set_min(value : Vector3) -> void:
	_min = value
	update_spring()

func update_spring() -> void:
	spring.position = position
	spring.velocity = velocity
	spring.target = target
	spring.damping = damping
	spring.speed = speed
	spring.mass = mass

func get_class() -> String:
	return "SpringArm3D"

func _ready() -> void:
	if get_parent().get_class() == "SpringArm3D":
		parent_spring = get_parent() as SpringArm3D
	elif get_parent().get_class() == "RigidBody":
		parent_physics_body = get_parent() as RigidBody

func _process(delta : float) -> void:
	spring.positionvelocity(delta)
	rotation = spring.position

func apply_impulse(position : Vector3, impulse : Vector3) -> void:
	#we will need to get a resistance of the spring
	#z values will be transmitted directly to parent springs
	var direction : Vector3 = position.normalized()
	var distance : float = position.length()
	var torque : Vector3 = position.cross(impulse)
	var dot : float = direction.dot(impulse)
	var parent_force : Vector3 = -direction * dot
	
	torque = torque / distance * inverse_inertia_tensor
	spring.apply_force(transform.basis.xform(torque))
	
	_apply_impulse(parent_force, torque.z)

func _apply_impulse(parent_force : Vector3, torque : float) -> void:
	#forces up the chain
	if parent_spring:
		parent_force = transform.basis.xform(parent_force)
		parent_spring.apply_impulse(transform.origin, parent_force)
		spring.apply_force(Vector3(0, 0, torque))
#	elif parent_physics_body:
#		var local_position = parent_physics_body.global_transform.basis.xform_inv(transform.origin)
#		parent_force = global_transform.basis.xform_inv(parent_force)
#		parent_physics_body.apply_impulse(local_position, parent_force)
#		parent_physics_body.apply_torque_impulse(torque_transmission * Vector3(0, 0, torque))
