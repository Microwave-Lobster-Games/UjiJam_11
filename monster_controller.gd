extends Sprite3D

@export var player : Player
@onready var visible_on_screen: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.eyes_changed.connect(spawn_dissapear)
	visible_on_screen.screen_exited.connect(dissapear)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

func spawn_dissapear(spawn : bool):
	print(spawn)
	if spawn:
		visible = false
	
	else:
		visible = true
		var rand_x = randf_range(-15, 15)
		var rand_z = randf_range(-15, 15)
		
		self.position = Vector3(rand_x, 1.027, rand_z)
	
	
