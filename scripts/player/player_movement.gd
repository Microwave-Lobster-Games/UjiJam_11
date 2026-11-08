extends CharacterBody3D
class_name Player

@export var SENSITIVITY: float = 0.1
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var eye_lids = $EyeLids
@onready var animation: AnimatedSprite3D = $AnimatedSprite3D
@export var step_sounds: Array[AudioStream]
signal eyes_changed(open : bool)
var is_on_the_ground: bool = false
@onready var stream_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var eyes_closed = false

var twist_input: float = 0.0
var pitch_input: float = 0.0
const SPEED = 5.0
var allow_close_eyes: bool = true
var timer: float = 0.0
var sound_index: int = 0
var allow_camera_movement: bool = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and allow_camera_movement:
		twist_input -= event.screen_relative.x * SENSITIVITY
		pitch_input -= event.screen_relative.y * SENSITIVITY
		pitch_input = clamp(pitch_input, -85, 85)
	
	if event is InputEventMouseButton:
		if event.get_button_index() == 1 and allow_close_eyes and is_on_the_ground: # left click
			eyes_closed = !eyes_closed
			open_close_eyes(eyes_closed)

func open_close_eyes(open : bool):
	eye_lids.visible = open
	emit_signal("eyes_changed", open)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		allow_camera_movement = false
		velocity.y -= gravity * delta
		if velocity.y != 0:
			timer += 1 * delta
		if timer > 5.0: 
			GameManager.end_game(false)
	
	else: 
		is_on_the_ground = true
		allow_camera_movement = true
		var input_dir := Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			animation.play("walking")
			
			if not step_sounds.is_empty() and not stream_player.playing:
				stream_player.stream = step_sounds[sound_index]
				stream_player.play()
				sound_index = (sound_index + 1) % step_sounds.size()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			animation.play("default")

	move_and_slide()

func _process(delta: float) -> void:
	var current_q = basis.get_rotation_quaternion()
	var twist_q = Quaternion(Vector3.UP, deg_to_rad(twist_input))
	var pitch_q = Quaternion(Vector3.RIGHT, deg_to_rad(pitch_input))
	var smoothed_q = current_q.slerp(twist_q * pitch_q, delta * 20.0)
	basis = Basis(smoothed_q)
