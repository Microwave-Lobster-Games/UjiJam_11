extends Sprite3D

@export var player : Player
@export var speed: float = 1.0
var attack_player: bool = false
@onready var visible_on_screen: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@onready var far_light: OmniLight3D = %"Far Light"

func _ready() -> void:
	player.eyes_changed.connect(spawn_dissapear)
	visible_on_screen.screen_exited.connect(dissapear)
	visible_on_screen.screen_entered.connect(attack)

func _process(delta: float) -> void:
	if attack_player and player and is_in_range(): 
		global_position = global_position.move_toward(player.global_position, speed * delta)
	
	if self.global_position.distance_to(player.global_position) <= 0.01: 
		GameManager.end_game(false)

func dissapear():
	var camera = get_viewport().get_camera_3d()
	var new_pos = Vector3.ZERO
	var attempts = 0
	var max_attempts = 10
	
	while attempts < max_attempts:
		var rand_x = randf_range(-15, 15)
		var rand_z = randf_range(-15, 15)
		new_pos = Vector3(rand_x, 1.027, rand_z)
		
		if not camera.is_position_in_frustum(new_pos):
			break
			
		attempts += 1
		
	self.position = new_pos
	attack_player = false

func spawn_dissapear(spawn : bool):
	#print(spawn)
	if spawn:
		visible = false
	
	else:
		visible = true
		var rand_x = randf_range(-15, 15)
		var rand_z = randf_range(-15, 15)
		
		self.position = Vector3(rand_x, 1.027, rand_z)

func attack() -> void:
	if not player: return
	attack_player = true

func is_in_range() -> bool: 
	return self.global_position.distance_to(player.global_position) <= far_light.omni_range
