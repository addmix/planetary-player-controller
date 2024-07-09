extends Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= deg_to_rad(event.relative.x * 0.1)
		rotation.x -= deg_to_rad(event.relative.y * 0.1)
