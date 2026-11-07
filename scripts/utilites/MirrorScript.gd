@tool
extends Node3D

@export var mirror_scene: PackedScene:
	set(value):
		mirror_scene = value

@export var mirror_count: int = 50 
@export var scatter_radius: float = 50.0
@export var min_scale: float = 0.7
@export var max_scale: float = 1.4
@export var seed_value: int = 12345

@export var ground_node: StaticBody3D 

@export var generate_in_editor: bool = false:
	set(value):
		if Engine.is_editor_hint():
			generate_trees()

func _ready() -> void:
	if not Engine.is_editor_hint():
		generate_trees()

func generate_trees() -> void:
	var children = get_children()
	for child in children:
		child.free()

	if not mirror_scene:
		printerr("Please assign a tree PackedScene!")
		return
		
	if not ground_node:
		printerr("Please assign the Ground StaticBody3D in the Inspector!")
		return

	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	var space_state = get_world_3d().direct_space_state
	var successful_spawns = 0
	var max_attempts = mirror_count * 4
	var attempts = 0

	for i in range(mirror_count):
		var hit_position = Vector3.ZERO
		var placed = false

		while not placed and attempts < max_attempts:
			attempts += 1
			var x = rng.randf_range(-scatter_radius, scatter_radius)
			var z = rng.randf_range(-scatter_radius, scatter_radius)
			
			var ray_origin = global_position + Vector3(x, 200.0, z)
			var ray_end = global_position + Vector3(x, -200.0, z)
			
			var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
			var result = space_state.intersect_ray(query)
			
			if result and result.collider == ground_node:
				hit_position = result.position
				placed = true

		if not placed:
			continue

		var tree_instance = mirror_scene.instantiate() as Node3D
		if not tree_instance:
			continue
			
		add_child(tree_instance)
		
		if Engine.is_editor_hint():
			tree_instance.owner = get_tree().edited_scene_root

		var scale_val = rng.randf_range(min_scale, max_scale)
		var rot_y = rng.randf_range(0, TAU)
		
		tree_instance.global_position = hit_position
		tree_instance.scale = Vector3(scale_val, scale_val, scale_val)
		tree_instance.rotation.y = rot_y
		
		successful_spawns += 1

	print("Successfully spawned ", successful_spawns, " tree scenes strictly on the ground!")
