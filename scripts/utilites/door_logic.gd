extends Sprite3D

@onready var audio_stream: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	audio_stream.stop()

func update_door_shader(is_open: bool) -> void:
	var mat = material_override as ShaderMaterial
	if mat:
		mat.set_shader_parameter("open_door", is_open)

func _process(_delta: float) -> void:
	var door_open = (GameManager.activated_keys >= 3)
	if GameManager.activated_keys >= 3 and not audio_stream.playing:
		audio_stream.play()
	update_door_shader(door_open)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player and GameManager.activated_keys >= 3:
		GameManager.end_game(true)
