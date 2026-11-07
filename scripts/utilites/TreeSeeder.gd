@tool
extends MultiMeshInstance3D

@export var tree_mesh: Mesh:
	set(value):
		tree_mesh = value
		if multimesh: 
			multimesh.mesh = tree_mesh
			
@export var tree_count: int = 200
@export var scatter_radius: float = 50.0
@export var min_scale: float = 0.7
@export var max_scale: float = 1.4
@export var seed_value: int = 12345
@export var tree_height: float = 2.0

@export var generate_in_editor: bool = false: 
	set(value):
		if Engine.is_editor_hint():
			generate_trees() 

func _ready() -> void: 
	if not Engine.is_editor_hint(): 
		generate_trees()

func generate_trees() -> void: 
	if not tree_mesh:
		printerr("Please assign a tree mesh to the MultiMeshInstance3D!")
		return
		
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_custom_data = true
	mm.mesh = tree_mesh
	mm.instance_count = tree_count
	multimesh = mm
	
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	for i in range(tree_count):
		var x = rng.randf_range(-scatter_radius, scatter_radius)
		var z = rng.randf_range(-scatter_radius, scatter_radius) 
		
		var scale_val = rng.randf_range(min_scale, max_scale)
		var rot_y = rng.randf_range(0, TAU)
		var y = (tree_height * scale_val) / 2.0
		
		var texture_index = rng.randi_range(0, 2)
		
		var t = Transform3D()
		t = t.scaled_local(Vector3(scale_val, scale_val, scale_val))
		t = t.rotated_local(Vector3.UP, rot_y)
		t.origin = Vector3(x, y, z)
		
		multimesh.set_instance_custom_data(i, Color(texture_index, 0, 0, 0))
		multimesh.set_instance_transform(i, t)
	
	print("Successfully seeded ", tree_count, " trees!")
