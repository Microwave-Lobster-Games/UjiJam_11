extends Node

@onready var button_retry: Button = $Button
@export var main_menu: PackedScene
@export var game_scene: PackedScene
@onready var texture_rect: TextureRect = $TextureRect
@onready var texture_rect_2: TextureRect = $TextureRect2

func _ready() -> void:
	button_retry.pressed.connect(_retry)

func setup(won: bool) -> void: 
	if won: 
		texture_rect.show()
		texture_rect_2.hide()
	else: 
		texture_rect.hide()
		texture_rect_2.show()
	
func _retry() -> void: 
	get_tree().change_scene_to_packed(game_scene)
	GameManager.reset()
	
