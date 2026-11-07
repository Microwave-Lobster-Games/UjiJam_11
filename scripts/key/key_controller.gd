extends Node3D

@onready var visible_on_screen: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@export var height: float = 10.0
@onready var player: Player = %Player

var key_tween: Tween = null
var is_activated: bool = false
var is_moving_down: bool = false


func _ready() -> void:
	player.eyes_changed.connect(key_reset)
	self.position = self.position + Vector3(0, height, 0)

func _process(_delta: float) -> void:
	if is_activated:
		return

	var is_player_close = global_position.distance_to(player.global_position) <= 10.0
	var is_looking_at_it = visible_on_screen.is_on_screen()

	if is_player_close and is_looking_at_it and not player.eyes_closed:
		if not is_moving_down and position.y > 1.0:
			start_moving_down()
	else:
		if position.y < height:
			key_reset(false)

func start_moving_down() -> void:
	is_moving_down = true
	
	if key_tween and key_tween.is_valid():
		key_tween.kill()
		
	key_tween = create_tween()
	key_tween.tween_property(self, "position:y", 1.0, 5.0)
	key_tween.finished.connect(_on_activation_finished)

func _on_activation_finished() -> void:
	if is_activated or global_position.distance_to(player.global_position) > 10.0:
		return
	is_activated = true
	GameManager.activated_keys += 1

func key_reset(open: bool) -> void:
	if open or is_activated: return
	is_moving_down = false
	if key_tween and key_tween.is_valid():
		key_tween.kill()
	key_tween = create_tween()
	key_tween.tween_property(self, "position:y", height, 5.0/height)
	key_tween.finished.connect(_on_activation_finished)
