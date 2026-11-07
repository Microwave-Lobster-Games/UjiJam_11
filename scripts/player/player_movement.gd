extends CharacterBody3D
class_name Player

@export var SENSITIVITY: float = 0.1
@onready var eye_lids = $EyeLids
signal eyes_changed(open : bool)

var eyes_closed = false

var twist_input: float = 0.0
var pitch_input: float = 0.0
const SPEED = 5.0
var allow_close_eyes: bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		twist_input -= event.screen_relative.x * SENSITIVITY
		pitch_input -= event.screen_relative.y * SENSITIVITY
		pitch_input = clamp(pitch_input, -85, 85)
	
	if event is InputEventMouseButton:
		if event.get_button_index() == 1 and allow_close_eyes: #left click
			eyes_closed = !eyes_closed
			open_close_eyes(eyes_closed)
			

func open_close_eyes(open : bool):
	eye_lids.visible = open
	emit_signal("eyes_changed", open)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process(delta: float) -> void:
	var current_q = basis.get_rotation_quaternion()
	var twist_q = Quaternion(Vector3.UP, deg_to_rad(twist_input))
	var pitch_q = Quaternion(Vector3.RIGHT, deg_to_rad(pitch_input))
	var smoothed_q = current_q.slerp(twist_q * pitch_q, delta * 20.0)
	basis = Basis(smoothed_q)
