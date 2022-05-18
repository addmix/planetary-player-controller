extends Spatial

onready var back : Spatial = self
onready var arms : Spatial = $Arms
onready var hands : Spatial = $Arms/Hands

onready var back_default_transform := transform
onready var arms_default_transform := arms.transform
onready var hands_default_transform := hands.transform

var arm_spring := Spring3D.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0.5, 10)
var hand_spring := Spring3D.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0.5, 10)
var back_spring := Spring3D.new(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0.5, 10)

func _physics_process(delta : float) -> void:
	back_spring._process(delta)
	arm_spring._process(delta)
	hand_spring._process(delta)
	
	back.rotation = back_spring.position
	arms.rotation = arm_spring.position
	hands.rotation = hand_spring.position
