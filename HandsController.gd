extends SpringArm3D

onready var back : SpringArm3D = self
onready var bicep : SpringArm3D = $Bicep
onready var forearm : SpringArm3D = $Bicep/Forearm
onready var hands : SpringArm3D = $Bicep/Forearm/Hands

onready var hand_impulse_position : Position3D = $Bicep/Forearm/Hands/ImpulsePosition
onready var brace_impulse_position : Position3D = $Bicep/Forearm/ImpulsePosition
onready var stock_impulse_position : Position3D = $ImpulsePosition
export var has_stock : bool = false
export var impulse_force : float = 3.5

func _physics_process(delta : float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("fire"):
		hands.apply_impulse(hand_impulse_position.transform.origin, hand_impulse_position.transform.basis.z * impulse_force)
#		forearm.apply_impulse(brace_impulse_position.transform.origin, brace_impulse_position.transform.basis.z * impulse_force)
#		back.apply_impulse(stock_impulse_position.transform.origin, stock_impulse_position.transform.basis.z * impulse_force)
