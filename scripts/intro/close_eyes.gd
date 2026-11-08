extends Control

@onready var credits: RichTextLabel = $EyeLids/Label2
@onready var eye_lids: ColorRect = $EyeLids/TextureRect
@onready var audio_stream: AudioStreamPlayer2D = $AudioStreamPlayer2D

var fade_duration: float = 1.0
var is_fading: bool = false 

func _ready() -> void: 
	credits.modulate = Color.TRANSPARENT
	eye_lids.modulate = Color.TRANSPARENT
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.get_button_index() == 1: # Left click
		if is_fading: 
			print("return") 
			return
		is_fading = true
		run_transition_sequence()

func run_transition_sequence() -> void:
	var tween = create_tween()
	tween.tween_property(eye_lids, "modulate", Color.BLACK, fade_duration)
	await tween.finished
	
	await get_tree().create_timer(1.0).timeout
	
	var text_tween = create_tween()
	text_tween.tween_property(credits, "modulate", Color.WHITE, fade_duration)
	await text_tween.finished
	
	await get_tree().create_timer(2.0).timeout
	
	var fade_out_tween = create_tween().set_parallel(true)
	fade_out_tween.tween_property(credits, "modulate", Color.TRANSPARENT, fade_duration)
	fade_out_tween.tween_property(audio_stream, "volume_db", -80, fade_duration)
	await fade_out_tween.finished
	
	get_tree().change_scene_to_file("res://main_forest.tscn")
