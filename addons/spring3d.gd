#class for 3D non-physics integrated springs, has to be explicitly updated using the positionvelocity() function.
#best for objects in 3D space, such as guns with recoil and bobbles.
extends Resource

#dependencies MathUtils in math_utils.gd, from https://github.com/addmix/godot_utils

class_name Spring3D

var inertia_tensor := Basis()
var position := Vector3.ZERO
var velocity := Vector3.ZERO
var target := Vector3.ZERO
var damper : float = 0
var speed : float = 1
var mass : float = 1

var clamp_x : bool = false
var clamp_y : bool = false
var clamp_z : bool = false
var _min := Vector3(0, 0, 0)
var _max := Vector3(0, 0, 0)

#base funcs
func _init(p := Vector3(0, 0, 0), v := Vector3(0, 0, 0), t := Vector3(0, 0, 0), d := 0.5, s := 1.0) -> void:
	position = p
	velocity = v
	target = t
	damper = d
	speed = s

func get_class() -> String:
	return "Spring3D"


#this basically just runs 3 1d springs together
#im pretty sure this will be effected by gimbal lock
#physics funcs
func _process(delta : float) -> void:
	if damper >= 1:
		return
	if speed == 0:
		push_error("Speed == 0 on Spring3D")
	
	var direction = position - target
	
	#round curve
	var curve = pow(1 - damper * damper, .5)
	#weird exponetial thingy
	var curve1 : Vector3 = (velocity / speed + damper * direction) / curve
	#hanging rope
	var cosine : float = cos(curve * speed * delta)
	#deflated bubble
	var sine : float = sin(curve * speed * delta)
	var e : float = pow(2.718281828459045, damper * speed * delta)
	
	var new_position : Vector3 = target + (direction * cosine + curve1 * sine) / e
	
	#clamped position
	var clamped_position := MathUtils.v3_clamp(new_position, _min, _max)
	position = MathUtils.v3_toggle_axis(Vector3(float(clamp_x), float(clamp_y), float(clamp_z)), clamped_position, position)
	velocity = speed * ((curve * curve1 - damper * direction) * cosine - (curve * direction + damper * curve1) * sine) / e

func apply_force(f : Vector3) -> void:
	velocity += f / mass

func accelerate(s : Vector3) -> void:
	velocity += s
