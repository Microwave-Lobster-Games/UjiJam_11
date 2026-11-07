extends Node3D

@onready var visible_on_screen: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D
@export var height = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = self.position + Vector3(0, height, 0)
	visible_on_screen.screen_entered.connect(move_down)
	visible_on_screen.screen_exited.connect(key_reset)

func move_down():
	pass

func key_reset():
	self.position = Vector3(self.position.x, height, self.position.z)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
