extends Sprite3D


func update_door_shader(is_open: bool) -> void: 
	var mat = material_override as ShaderMaterial
	if mat:
		mat.set_shader_parameter("open_door", is_open)

func _process(_delta: float) -> void: 
	update_door_shader(GameManager.activated_keys == 3)
