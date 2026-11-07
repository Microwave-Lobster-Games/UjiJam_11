extends Node

@onready var label: Label = $CanvasLayer/VBoxContainer/Label
@onready var button_retry: Button = $CanvasLayer/VBoxContainer/HBoxContainer/Button
@onready var button_menu: Button = $CanvasLayer/VBoxContainer/HBoxContainer/Button2
@export var main_menu: PackedScene
@export var game_scene: PackedScene

func _ready() -> void:
	button_retry.pressed.connect(_retry)
	button_menu.pressed.connect(_change_scene)

func setup(text_plc: String) -> void: 
	label.text = text_plc
	
func _retry() -> void: 
	get_tree().change_scene_to_packed(game_scene)
	GameManager.reset()
	
func _change_scene() -> void: 
	get_tree().change_scene_to_packed(main_menu)
	GameManager.reset()
