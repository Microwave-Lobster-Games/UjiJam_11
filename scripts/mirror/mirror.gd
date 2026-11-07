@tool
extends Node3D

@onready var quad: MeshInstance3D = $Quad
@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera_3d: Camera3D = $SubViewport/Camera3D

@export var size: Vector2 = Vector2(10, 10):
	set(v):
		size = v
		quad.mesh.size = size
		sub_viewport.size = size * pixels_per_unit
	
@export var pixels_per_unit: int = 200
@export var cull_near: float = 0.05
@export var cull_far: float = 50.0
@export_flags_3d_render var cull_mask: int = 0xFFFFF
@export var max_update_distance: float = 50.0

var last_main_cam_pos: Vector3
var main_cam: Camera3D 

func _ready() -> void: 
	if Engine.is_editor_hint():
		main_cam = Engine.get_singleton(&"EditorInterface").get_editor_viewport_3d().get_camera_3d()
	else: 
		main_cam = get_viewport().get_camera_3d()
	
	last_main_cam_pos = main_cam.global_position
	setup()
	update_cam()

func setup() -> void: 
	var viewport_texture = sub_viewport.get_texture()
	camera_3d.cull_mask = cull_mask
	camera_3d.fov = main_cam.fov
	quad.mesh.size = size
	sub_viewport.size = size * pixels_per_unit
	quad.get_active_material(0).set_shader_parameter(&"tex", viewport_texture)
	
	
func update_cam() -> void: 
	var mirror_normal = quad.global_basis.z
	var mirror_transform = get_mirror_transform(mirror_normal, global_position)
	camera_3d.global_transform = mirror_transform * main_cam.global_transform
	
	camera_3d.global_transform = camera_3d.global_transform.looking_at(
		camera_3d.global_position / 2.0 + last_main_cam_pos / 2.0, quad.global_basis.y)
	var camera_to_mirror_offset = quad.global_position - camera_3d.global_position

	var near = abs(camera_to_mirror_offset.dot(mirror_normal)) + cull_near
	var far = camera_to_mirror_offset.length() + cull_far
	var cam_to_mirror_offset_camera_local = camera_3d.global_basis.inverse() * camera_to_mirror_offset
	var frustum_offset = Vector2(cam_to_mirror_offset_camera_local.x, cam_to_mirror_offset_camera_local.y)
	camera_3d.set_frustum(size.x, frustum_offset, near, far)
	
static func get_mirror_transform(normal: Vector3, offset: Vector3) -> Transform3D: 
	var basis_x = Vector3.RIGHT - (2 * Vector3(normal.x * normal.x, normal.x * normal.y, normal.x * normal.z))
	var basis_y = Vector3.UP 	- (2 * Vector3(normal.y * normal.x, normal.y * normal.y, normal.y * normal.z))
	var basis_z = Vector3.BACK 	- (2 * Vector3(normal.z * normal.x, normal.z * normal.y, normal.z * normal.z))
	var origin = 2 * normal.dot(offset) * normal
	return Transform3D(basis_x, basis_y, basis_z, origin)

func _process(_delta: float) -> void:
	if !is_visible_in_tree(): return
	if !is_instance_valid(main_cam): return
	if last_main_cam_pos.distance_to(main_cam.global_position) < 0.01: return
	
	last_main_cam_pos = main_cam.global_position
	var diff = global_position - last_main_cam_pos
	if diff.length() > max_update_distance: 
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	else: 
		sub_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
		
	update_cam() 
	
