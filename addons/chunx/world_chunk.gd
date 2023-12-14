@tool
class_name WorldChunk
extends Node3D


@export var chunk:Vector3i
var cache:Dictionary = {}


signal recalculate_node(n:Node)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not Engine.is_editor_hint():
		return
	
	for c in get_children():
		if cache.has(c):
			if not (c as Node3D).position == cache[c]:
				recalculate_node.emit(c)
				cache[c] = c.position
		else:
			cache[c] = c.position
	
	for c in cache:
		if not get_children().has(c):
			cache.erase(c)


func save() -> PackedScene:
	var ps = PackedScene.new()
	
	for c in get_children():
		set_children_owner(c)
	
	ps.pack(self)
	
	return ps


func set_children_owner(n:Node) -> void:
	n.owner = self
	for c in n.get_children():
		set_children_owner(c)
