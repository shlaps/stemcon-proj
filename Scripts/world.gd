# unfortunately this is very messy code
# but shhhhh it works
#idek where to begin with organizing this honestly
#its not as bad as the burd code tbh
#maybe none of this is actually that bad and im just suffering insane amouts of burnout
# still having fun though!!!!!!!!!!!
#js wish i had more time to do hw :sob:

extends Node2D
class_name world

@onready var TileMapObj = $TileMap
@onready var TileTimers = $TileTimers
@onready var dayTimer = $DayTimer as Timer

var currentTime = 0
@export var times = [10, 10, 10] #day, afternoon, night respectively, can be changed in editor

var timeColor = [Color.AQUAMARINE, Color.NAVY_BLUE, Color.BLACK]

signal timeChanged

var tile_coords = [
	Vector2(1,1),
	Vector2(0,1),
	Vector2(1,0),
	Vector2(0,0)
]

@onready var sky = $Sky

var target : Camera2D
var update = false
var gt_prev : Transform2D
var gt_current : Transform2D
	
func update_transform():
	gt_prev = gt_current
	gt_current = target.global_transform
	


func _process(_delta):
	#move sky, looks shitty for somereason if its not a solid color. doesn't matter for this project anyways
	#you could simplify this a lot for smt this simple, but idc
	if update:
		update_transform()
		update = false
		
	var f = clamp(Engine.get_physics_interpolation_fraction(), 0, 1)
	sky.global_transform = gt_prev.interpolate_with(gt_current, f)


func on_tile_grow(tileTimer, tile_pos):
	var tile_data = TileMapObj.get_cell_tile_data(0, tile_pos) as TileData
	var isOccupied = tile_data.get_custom_data_by_layer_id(1)
	var vegetationLevel = tile_data.get_custom_data_by_layer_id(0)
	if vegetationLevel >= 3:
		return
	
	if tile_data and isOccupied:
		TileMapObj.set_cell(0, tile_pos, 1, tile_coords[vegetationLevel + 1], 1)
	elif tile_data and not isOccupied:
		TileMapObj.set_cell(0, tile_pos, 1, tile_coords[vegetationLevel + 1])
	tileTimer.set_wait_time(randf_range(60.0, 180.0))
	

func _ready() -> void:	
	sky.visible = true
	dayTimer.wait_time = times[currentTime]
	print(times[currentTime])
	sky.modulate = timeColor[currentTime]
	dayTimer.start()
	#grow timer setup
	for i in TileMapObj.get_used_cells(0):
		var tile_data = TileMapObj.get_cell_tile_data(0, i) as TileData
		var vegetationLevel = tile_data.get_custom_data_by_layer_id(0)
		
		if vegetationLevel == -1: # wall / other obstacle or howver the fuck u spell it
			continue
		
		var tileTimer = Timer.new()
		tileTimer.set_wait_time(randf_range(30.0, 180.0))  # set a random initial wait time
		TileTimers.add_child(tileTimer)
		tileTimer.connect("timeout", Callable(self, "on_tile_grow").bind(tileTimer, i))
		tileTimer.start()
		
	#move sky
	target = $Camera2D
	sky.global_transform = target.global_transform
	
	gt_prev = target.global_transform
	gt_current = target.global_transform
	

func _physics_process(_delta: float) -> void:
	update = true
	if Input.is_action_just_pressed("pause_game"):
		Engine.time_scale = 0
	elif Input.is_action_just_pressed("set_speed_two"):
		Engine.time_scale += 1
	elif Input.is_action_just_pressed("set_speed_one"):
		Engine.time_scale -= 1

func _on_day_timer_timeout() -> void:
	currentTime += 1
	if currentTime > 2:
		currentTime = 0
	
	sky.modulate = timeColor[currentTime]
	dayTimer.wait_time = times[currentTime]
	dayTimer.start()
	timeChanged.emit(currentTime)
	
	
	
	
	# data collection stuff
	
	
