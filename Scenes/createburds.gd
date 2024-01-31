extends Node
@export var burdScene : PackedScene 
@export var desiredNumber : int = 100


@onready var TileMapObj =  $"/root/World/TileMap" as TileMap

func _ready() -> void:	
	var currentNumber = 0
	var tileTable = TileMapObj.get_used_cells(0).duplicate()
	tileTable.shuffle()
	
	for i in tileTable:
		var pos = TileMapObj.map_to_local(i)
		var tile_data = TileMapObj.get_cell_tile_data(0, i) as TileData
		var isOccupied = tile_data.get_custom_data_by_layer_id(1)
		var isWall = tile_data.get_custom_data_by_layer_id(2)
		
		if isWall or isOccupied:
			continue
		var newBurd = burdScene.instantiate() as burd
		newBurd.position = pos
		add_child(newBurd)
		currentNumber += 1
		if currentNumber >= desiredNumber:
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
