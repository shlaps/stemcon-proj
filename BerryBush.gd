extends Node2D
class_name plant # maybe use inherited scene, more vegetation types ?!?!?!

@export var maxUses : int = 4
var uses : int = 1

@onready var sprite = $Sprite2D as Sprite2D
@onready var WorldNode = $"/root/World" as world
@onready var tileMap = WorldNode.find_child("TileMap") as TileMap

@onready var size = sprite.scale.x

func _ready() -> void:
	var tileTable = tileMap.get_used_cells(0).duplicate()
	tileTable.shuffle()
	var selectedTile = tileTable[0] #random tile sel
	
	var tile_data = tileMap.get_cell_tile_data(0, selectedTile) as TileData
	var vegetationLevel = tile_data.get_custom_data_by_layer_id(0)
		
	if vegetationLevel == -1 or vegetationLevel == null: # wall / other obstacle or howver the fuck u spell it
		_ready()
		return
		
	position = tileMap.map_to_local(selectedTile)
	sprite.visible = true

func consume():
	uses += 1
	sprite.scale = Vector2(size / uses, size / uses)
	
	if uses >= maxUses:
		queue_free()
