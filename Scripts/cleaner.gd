extends Node

@onready var TileMapObj = $"/root/World/TileMap"
@onready var Area = $Area2D

@export var timeToNextClean = 400

func _ready() -> void:
	$Timer.wait_time = timeToNextClean
	$Timer.start()

var tile_coords = [
	Vector2(1,1),
	Vector2(0,1),
	Vector2(1,0),
	Vector2(0,0)
]

func _on_timer_timeout() -> void: # we shoulddd just fix whatever bug is causing this but wtv, we shoulddd also just lerp the sprite and move the rest of the organism instantly, but idc
	var cleanList = TileMapObj.get_used_cells(0).duplicate()
	cleanList.shuffle()
	
	for i in cleanList:
		var tile_pos = TileMapObj.map_to_local(i)
		var tile_data = TileMapObj.get_cell_tile_data(0, i) as TileData
		var isColliding = tile_data.get_custom_data_by_layer_id(1)
		var isWall = tile_data.get_custom_data_by_layer_id(2)
		var vegetationLevel = tile_data.get_custom_data_by_layer_id(0)
		
		Area.position = tile_pos
		await get_tree().create_timer(0.03).timeout
		if Area.get_overlapping_areas().is_empty() and not isWall and isColliding:
			TileMapObj.set_cell(0, i, 1, tile_coords[vegetationLevel])
	$Timer.start()
