extends CanvasLayer

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_viewport().get_mouse_position()
		var found_areas = []
		
		# Check all children of this CanvasLayer
		_find_area2d_children(self, mouse_pos, found_areas)
		
		print("Area2D nodes in CanvasLayer at position ", mouse_pos, ":")
		if found_areas.size() > 0:
			for area in found_areas:
				print(" - ", area.name)
		else:
			print("No Area2D nodes found")

func _find_area2d_children(node: Node, position: Vector2, results: Array):
	for child in node.get_children():
		print(child)
		if child is Card:
			if _is_point_in_area2d(child, position):
				results.append(child)
		# Recursively check grandchildren
		_find_area2d_children(child, position, results)

func _is_point_in_area2d(area: Area2D, point: Vector2) -> bool:
	for child in area.get_children():
		if child is CollisionShape2D and child.shape:
			var transform = area.global_transform * child.transform
			if child.shape.collide(transform, point):
				return true
	return false
