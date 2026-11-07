extends Camera3D


const SENSITIVITY: float = 0.1

var twist_input: float = 0.0
var pitch_input: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		twist_input -= event.screen_relative.x * SENSITIVITY
		pitch_input -= event.screen_relative.y * SENSITIVITY
		pitch_input = clamp(pitch_input, -85, 85)


func _process(delta: float) -> void:
	var current_q = basis.get_rotation_quaternion()
	var twist_q = Quaternion(Vector3.UP, deg_to_rad(twist_input))
	var pitch_q = Quaternion(Vector3.RIGHT, deg_to_rad(pitch_input))
	var smoothed_q = current_q.slerp(twist_q * pitch_q, delta * 20.0)
	basis = Basis(smoothed_q)
