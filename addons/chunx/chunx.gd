@tool
extends EditorPlugin


func _process(_delta: float) -> void:
	# make sure there are nodess selected
	var s = EditorInterface.get_selection()
	if s.get_transformable_selected_nodes().is_empty(): return
	#get streamer node, return if none
	var streamer:WorldStreamer
	var p:Node = s.get_transformable_selected_nodes()[0]
	while not p.get_parent() == null:
		if p is WorldStreamer:
			streamer = p
			break
		p = p.get_parent()
	if streamer == null:
		return
	# sort all selected node
	for i:Node in s.get_transformable_selected_nodes():
		if i is WorldChunk: continue # skip chunks
		if i.get_parent() is WorldStreamer: # sort unsorted nodes and continue
			print("Unsorted node")
			streamer._sort_into_chunk(i)
			i.get_parent().child_order_changed.connect(func(): s.add_node(i), CONNECT_ONE_SHOT)
			await streamer.reparenting_done
			continue
		if not i.get_parent() is WorldChunk: continue # only sort direct children of chunks
		if not i is Node3D: continue # only sort node3d
		
		if (not streamer.chunk_map.has(streamer.get_coords_for_point((i as Node3D).position)))\
			or (not streamer.chunk_map[streamer.get_coords_for_point((i as Node3D).position)] == i.get_parent()): # if streamer has no chunk made or incorrect chunk 
			print("improper chunk")
			# if the chunk underneath the correct point is not the chunk it should be, resort it
			streamer._sort_into_chunk(i)
			await streamer.reparenting_done
			s.add_node.call_deferred(i) # selection gets cleared upon reparenting
