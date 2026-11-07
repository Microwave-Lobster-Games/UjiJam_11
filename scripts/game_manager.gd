extends Node

var activated_keys: int = 0
var is_door_open: bool = false
@export var end_game_text: PackedScene


func _process(_delta: float) -> void:
	if activated_keys == 3 and not is_door_open: 
		is_door_open = true
	
func end_game(win: bool) -> void: 
	if win: 
		pass
		
	else: 
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		show_text(false)

func show_text(win: bool) -> void: 
	var text_scene = end_game_text.instantiate()
	add_child(text_scene)
	if win: 
		text_scene.setup("You won")
	else:
		text_scene.setup("Skill issue")

func reset() -> void: 
	get_tree().paused = false
	activated_keys = 0
	for child in get_children(): 
		remove_child(child)
