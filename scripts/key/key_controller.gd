extends Node3D

@onready var visible_on_screen: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@export var height: float = 10.0
@onready var player: Player = %Player
@onready var monster: Sprite3D = %Monster
@onready var audio_stream: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var sounds: Array[AudioStream]
var key_tween: Tween = null
var is_activated: bool = false
var is_moving_down: bool = false
@export var eye_closed: AtlasTexture
@onready var sprite_3d: Sprite3D = $Sprite3D

func _ready() -> void:
	player.eyes_changed.connect(key_reset)
	self.position = self.position + Vector3(0, height, 0)

func _process(_delta: float) -> void:
	if is_activated:
		return

	var is_player_close = global_position.distance_to(player.global_position) <= 10.0
	var main_camera: Camera3D = get_viewport().get_camera_3d()
	var is_looking_at_it = false
	
	if main_camera:
		is_looking_at_it = main_camera.is_position_in_frustum(global_position)
	
	if not sounds.is_empty():
		if audio_stream.stream != sounds[2] or not audio_stream.is_playing():
			audio_stream.stream = sounds[2]
			audio_stream.play()
			
	if is_player_close and is_looking_at_it and not player.eyes_closed:
		if not is_moving_down and position.y > 1.0:
			monster.dissapear()
			monster.spawn_dissapear(false)
			start_moving_down()
			if not sounds.is_empty():
				if audio_stream.stream != sounds[0] or not audio_stream.is_playing():
					audio_stream.stream = sounds[0]
					audio_stream.play()
	else:
		if position.y < height:
			key_reset(false)

func start_moving_down() -> void:
	is_moving_down = true
	
	if key_tween and key_tween.is_valid():
		key_tween.kill()
		
	key_tween = create_tween()
	key_tween.tween_property(self, "position:y", 1.0, 5.0)
	key_tween.finished.connect(_on_activation_finished)

func _on_activation_finished() -> void:
	if is_activated or global_position.distance_to(player.global_position) > 10.0:
		return
	is_activated = true
	sprite_3d.texture = eye_closed
	if not sounds.is_empty():
		if audio_stream.stream != sounds[1] or not audio_stream.is_playing():
			audio_stream.stream = sounds[1]
			audio_stream.play()
	monster.far_light.omni_range += 5
	monster.close_light.omni_range += 5
	GameManager.activated_keys += 1
	GameManager.paranoia_fill_speed += 10
	

func key_reset(open: bool) -> void:
	if open or is_activated: return
	is_moving_down = false
	if key_tween and key_tween.is_valid():
		key_tween.kill()
	key_tween = create_tween()
	key_tween.tween_property(self, "position:y", height, 5.0/height)
	key_tween.finished.connect(_on_activation_finished)
