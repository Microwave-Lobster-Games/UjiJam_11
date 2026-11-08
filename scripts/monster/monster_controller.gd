extends Sprite3D

@export var player : Player
@export var radius_spawn: float = 20
@export var speed: float = 25.0
@onready var visible_on_screen: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@onready var far_light: OmniLight3D = %"Far Light"
@onready var close_light: OmniLight3D = %CloseLight
@onready var audio_stream: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var sounds: Array[AudioStream]

func _ready() -> void:
	player.eyes_changed.connect(spawn_dissapear)
	visible_on_screen.screen_exited.connect(dissapear)

func _process(delta: float) -> void:
	if not sounds.is_empty():
		if audio_stream.stream != sounds[0] or not audio_stream.is_playing():
			audio_stream.stream = sounds[0]
			audio_stream.play()
	if player and is_in_range(): 
		if sounds.size() > 1:
			if audio_stream.stream != sounds[1] or not audio_stream.is_playing():
				audio_stream.stream = sounds[1]
				audio_stream.play()
		global_position = global_position.move_toward(player.global_position, speed * delta)
	
	if self.global_position.distance_to(player.global_position) <= 0.01: 
		GameManager.end_game(false)

func dissapear():
	var camera = get_viewport().get_camera_3d()
	var spawn_pos = Vector3.ZERO
	var attempts = 0
	var max_attempts = 10
	
	while attempts < max_attempts:
		var min_distance = far_light.omni_range if far_light else 5.0
		var max_distance = radius_spawn
		
		if max_distance <= min_distance:
			max_distance = min_distance + 5.0
			
		var angle = randf() * TAU
		var distance = randf_range(min_distance, max_distance)
		
		var offset_x = cos(angle) * distance
		var offset_z = sin(angle) * distance
		
		var test_pos = player.global_position + Vector3(offset_x, 1.027, offset_z)
		
		if not camera or not camera.is_position_in_frustum(test_pos):
			spawn_pos = test_pos
			break
			
		attempts += 1
	
	if spawn_pos == Vector3.ZERO:
		spawn_dissapear(false)
		return

	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(spawn_pos + Vector3(0, 50, 0), spawn_pos + Vector3(0, -50, 0))
	var result = space_state.intersect_ray(ray_query)
	
	if result:
		spawn_pos = result.position
		 
	spawn_pos.y = 1.027	
	self.global_position = spawn_pos
	visible = true
	
func spawn_dissapear(spawn : bool):
	if spawn:
		visible = false
	else:
		visible = true
		
		var min_distance = far_light.omni_range if far_light else 5.0
		var max_distance = radius_spawn
		
		if max_distance <= min_distance:
			max_distance = min_distance + 5.0
		
		var angle = randf() * TAU
		var distance = randf_range(min_distance, max_distance)
		
		var offset_x = cos(angle) * distance
		var offset_z = sin(angle) * distance
		
		var spawn_pos = player.global_position + Vector3(offset_x, 50.0, offset_z)
		
		var space_state = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.create(spawn_pos, spawn_pos + Vector3(0, -100.0, 0))
		var result = space_state.intersect_ray(ray_query)
		
		if result:
			spawn_pos = result.position
			
		
		spawn_pos.y = 1.027	
		self.global_position = spawn_pos


func is_in_range() -> bool: 
	return self.global_position.distance_to(player.global_position) <= far_light.omni_range
