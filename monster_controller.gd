extends Sprite3D

@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.eyes_changed.connect(spawn_dissapear)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_dissapear(spawn : bool):
	print(spawn)
	if spawn:
		visible = false
	
	else:
		visible = true
		var rand_x = randf_range(-15, 15)
		var rand_z = randf_range(-15, 15)
		
		self.position = Vector3(rand_x, 1.027, rand_z)
	
	
