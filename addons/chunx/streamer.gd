@tool
class_name WorldStreamer
extends Node3D


@export var chunk_sizes:Vector3 = Vector3(16, 16, 16) ## Size of each chunk.
@export_range(0, 100, 1, "or_greater") var chunk_load_radius:int = 5 ## How many chunks are loaded around the camera.
@export_range(0, 100, 1, "or_greater") var chunk_load_min_radius:int = 0 ## Chunks are not loaded inside this range. Use to create a "ring".
@export_dir() var chunk_dir:String ## Where chunk data is saved to.
var chunk_map:Dictionary = {}
var cam_cache:Vector3i

signal reparenting_done()


# Called when the node enters the scene tree for the first time.
func _ready():
	#if Engine.is_editor_hint():
		#child_entered_tree.connect(_process_node.bind())
	
	for c in get_children():
		if c is WorldChunk:
			chunk_map[(c as WorldChunk).chunk] = c


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var cam = _grab_camera() # TODO: get editor camera if in editor
	var cam_cell = get_coords_for_point(cam.position)
	if not cam_cell == cam_cache:
		var cells = get_cells_in_radius(cam.position)
		# 1. Cull chunks that aren't in circle, saving if in editor
		for c in chunk_map:
			if not cells.has(c):
				remove_cell(chunk_map[c])
		# 2. Try spawn chunks that don't exist but are in circle
		for c in cells:
			if not chunk_map.has(c):
				load_cell(c)
	cam_cache = cam_cell


func remove_cell(chunk:WorldChunk) -> void:
	if Engine.is_editor_hint():
		var scene = chunk.save()
		ResourceSaver.save(scene, "%s/%s.tscn" % [chunk_dir, chunk.chunk])
	
	chunk_map.erase(chunk.chunk)
	chunk.queue_free() # ! Could crash, be careful


func load_cell(v:Vector3i) -> void:
	var path = "%s/%s.tscn" % [chunk_dir, v]
	if not FileAccess.file_exists(path):
		return
	
	var res = load(path)
	if res == null:
		return
	
	var scene:Node = res.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	add_child(scene)
	scene.name = "%s" % scene.chunk
	chunk_map[scene.chunk] = scene
	
	if Engine.is_editor_hint():
		set_editable_instance(scene, true)
		scene.set_owner(get_tree().edited_scene_root)
		for c in scene.get_children():
			c.set_owner(get_tree().edited_scene_root)


func _create_chunk(v:Vector3i) -> WorldChunk:
	var ch = WorldChunk.new()
	ch.chunk = v
	ch.name = "%s" % v
	#ch.recalculate_node.connect(_process_node.bind())
	chunk_map[ch.chunk] = ch
	add_child(ch)
	ch.set_owner(get_tree().edited_scene_root)
	print("Creating chunk: %s - %s" % [ch, v])
	return ch


func _sort_into_chunk(n:Node3D) -> void:
	print("Sorting %s into chunk" % n)
	var coords = get_coords_for_point(n.position)
	print(coords)
	if chunk_map.has(coords):
		print("Chunk found.")
		#if n.get_parent() is WorldChunk:
			#n.get_parent().save()
		_reparent_object(n, coords)
	else:
		print("Chunk must be created.")
		var ch = _create_chunk(coords) # has trouble with creating chunks and then reparenting
		ch.ready.connect(_reparent_object.bind(n, coords), CONNECT_ONE_SHOT)


func _reparent_object(n:Node3D, coords:Vector3i) -> void:
	print("reparenting.")
	n.reparent(chunk_map[coords])
	n.set_owner(get_tree().edited_scene_root)
	reparenting_done.emit()
	#chunk_map[coords].save()


func get_coords_for_point(pt:Vector3) -> Vector3i:
	return Vector3i(
		floori(pt.x / chunk_sizes.x),
		floori(pt.y / chunk_sizes.y),
		floori(pt.z / chunk_sizes.z),
	)


func get_cells_in_radius(pt:Vector3) -> Array[Vector3i]:
	var center = get_coords_for_point(pt)
	var start = Vector3i(center.x + chunk_load_radius, center.y + chunk_load_radius, center.z + chunk_load_radius)
	var end = Vector3i(center.x - chunk_load_radius, center.y - chunk_load_radius, center.z - chunk_load_radius)
	
	var output:Array[Vector3i] = []
	
	for x in range(end.x, start.x):
		for y in range(end.y, start.y):
			for z in range(end.z, start.z):
				var dist =  Vector3(x,y,z).distance_squared_to(center)
				if dist < chunk_load_radius ** 2 and dist > chunk_load_min_radius ** 2:
					output.append(Vector3i(x,y,z))
	
	return output


func _grab_camera() -> Camera3D:
	# TODO: Cache
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_viewport_3d(0).get_camera_3d()
	else:
		return get_viewport().get_camera_3d()
