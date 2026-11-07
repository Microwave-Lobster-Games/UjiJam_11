class_name ParanoiaMeter
extends Slider

const MAX_METER: float = 10.0
const FILL_SPEED: float = 1.0
const DRAIN_SPEED: float = 1.0

var current_meter: float = 0.0
var is_increasing: bool = false
var punish_timer: float = 0.0

@export var player: Player

func _ready() -> void:
	max_value = MAX_METER
	value = current_meter
	
	if player:
		player.eyes_changed.connect(_on_eyes_changed)

func _on_eyes_changed(open: bool) -> void:
	is_increasing = open

func _process(delta: float) -> void:
	if punish_timer > 0.0:
		punish_timer -= delta
		current_meter -= DRAIN_SPEED * delta
		if current_meter <= 0.0:
			current_meter = 0.0
		value = current_meter
		if punish_timer <= 0.0:
			punish_timer = 0.0
			if player:
				player.allow_close_eyes = true
		return 

	if is_increasing:
		current_meter += FILL_SPEED * delta
		if current_meter >= MAX_METER:
			current_meter = MAX_METER
			_trigger_punishment()
	else:
		current_meter -= DRAIN_SPEED * delta
		if current_meter <= 0.0:
			current_meter = 0.0

	value = current_meter

func _trigger_punishment() -> void:
	if player:
		player.eyes_closed = !player.eyes_closed
		player.open_close_eyes(player.eyes_closed)
		player.allow_close_eyes = false
	punish_timer = MAX_METER
	is_increasing = false
