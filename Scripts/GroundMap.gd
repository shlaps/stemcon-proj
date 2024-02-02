extends TileMap
@export var occupiedMarker : PackedScene

var enableMarkers = false
	
func _process(_delta: float) -> void:
	if enableMarkers:
		for i in get_children():
			i.queue_free()
	
		for i in get_used_cells(0):
			var tile_data = get_cell_tile_data(0, i)
			var veg_data = tile_data.get_custom_data_by_layer_id(1)
			var isWall = tile_data.get_custom_data_by_layer_id(2)
			if tile_data and veg_data == true and not isWall:
				var indicator = occupiedMarker.instantiate() as Sprite2D
				add_child(indicator)
				indicator.global_position = map_to_local(i)

	if Input.is_action_just_pressed("debug_enable"):
		enableMarkers = not enableMarkers
		for i in get_children():
			i.queue_free()
	
