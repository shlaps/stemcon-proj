extends Node
@export var burdScene : PackedScene 
@export var desiredNumber : int = 100

var minute = 0


@onready var TileMapObj =  $"/root/World/TileMap" as TileMap

func collectData():
	var freqXX = 0
	var freqXx= 0
	var freqxx = 0
	for i in get_children(): # this is bad but i have less than a day to do this + data anylysis so i dont care
		if i is Timer: continue
		if i.genotype == "XX":
			freqXX += 1
		elif  i.genotype == "Xx":
			freqXx += 1
		else:
			freqxx += 1
	print("Minute: " , minute, " || Amount XX: ", freqXX, " Amount Xx: ", freqXx, " Amount xx: ", freqxx)

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
	print("|| DAY 0 ||")
	collectData()
	


func _on_data_collection_timer_timeout() -> void:
	minute += 1
	collectData()

var pop = 0
@export var popCap = 1000
func _on_child_entered_tree(node: Node) -> void:
	if node is burd:
		pop += 1
		if pop >= popCap:
			await node._ready()
			node.die()


func _on_child_exiting_tree(node: Node) -> void:
	if node is burd:
		pop -= 1
