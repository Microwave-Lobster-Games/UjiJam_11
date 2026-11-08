extends Sprite3D

@onready var visible_on_screen: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@export var player: Player
var is_connected: bool = false

func _ready() -> void:
	if player:
		player.eyes_changed.connect(dissapear)

func dissapear(open: bool) -> void: 
	if open: 
		return
	else: 
		self.hide()

func remove_from_screen() -> void: 
	self.hide()

func _process(_delta: float) -> void: 
	if player and player.is_on_floor() and not is_connected: 
		visible_on_screen.screen_exited.connect(remove_from_screen)
		is_connected = true
