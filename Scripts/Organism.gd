#functionally this is mostly fine besides the pathing which is probably causing a loss of performance
# its just really bad readability wise
# for the love of god if you look at this github as an example PLEASE PLEASE PLEASE inherit ur scenes
# base class (all the funtions each organism needs) -> animals and plants(?) -> specific species
# this would change based on what ur project is but please if u learn anything from this !!!!!!!!!!!!!!!!!USE INHERITED SCENES!!!!!!!!!!!!!!!!!

extends Node2D
class_name burd

var maxHunger = 30.0
var hunger = maxHunger / 2

var maxHealth = 3.0
var health = maxHealth
var turnsTilHunger = 2
var hungerCount = 0
var metabolism = randf_range(1.0, 5.0)

var canBreed = true
var isChild = false
var shouldHide = false
var isHiding = false

var genotypes = {
		"BB" = Color.DARK_GREEN,
		"Bb" = Color.DARK_GREEN,
		"bb" = Color.WHITE
	}
	
var visRate = 100.0
var genotype

signal clicked

@onready var animator = $AnimationPlayer as AnimationPlayer
@onready var turnTimer = $TurnCooldown as Timer
@onready var hpMeter = $HealthMeter as ProgressBar
@onready var hungerMeter = $HungerMeter as ProgressBar
@onready var WorldNode = $"/root/World" as world
@onready var tile = WorldNode.find_child("TileMap") as TileMap

var tile_coords = [
	
	Vector2(1,1),
	Vector2(0,1),
	Vector2(1,0),
	Vector2(0,0)
	]
	
func compColor(base, comparer = $Sprite2D.modulate): #sprite color, tile color
	var invisRate = 0
		
	var CompColor = base - comparer
	CompColor.r = abs(CompColor.r)
	CompColor.g = abs(CompColor.g)
	CompColor.b = abs(CompColor.b)
	
	invisRate += 1 - CompColor.r
	invisRate += 1 - CompColor.g
	invisRate += 1 - CompColor.b
	
	invisRate /= 3
	invisRate = pow(invisRate, 2)
	return invisRate # incase of future use - the color will reutrn transparent (CompColor.a = 1 after calculating value to fix)

func setOccupied(boolValue, pos = position):
	var currentTile = findVegetationData(pos)
	var tile_data = currentTile.get("tile_data") as TileData
	if tile_data == null:
		return
	var tile_pos = currentTile.get("tile_pos")
	var atlas_coords = tile.get_cell_atlas_coords(0, tile_pos)
	var vegetationLevel = currentTile.get("vegetation_data")
	
	if vegetationLevel == -1: # ignore non-vegetation tiles, like hidng spots. hopefully when i implement trees this will go away. since this tile has no occupied varrient, we just return. but needed use tile.get_cell_alternative_tile(0, tile_pos) to get the ALTID
		return
	
	


	if tile_data and boolValue:
		tile.set_cell(0, tile_pos, 1, atlas_coords, 1)
	elif tile_data and not boolValue:
		tile.set_cell(0, tile_pos, 1, atlas_coords)

func findVegetationData(pos):
	if pos == null: return
	var tileTable = {
		"tile_pos" = null,
		"tile_data" = null,
		"vegetation_data" = null,
		"isOccupied" = null,
		"isWall" = null,
		"tileColor" = null
 	}
	
	var tile_pos = tile.local_to_map(pos)
	var tile_data = tile.get_cell_tile_data(0, tile_pos)
	
	if tile_data == null:
		return tileTable
		
		
	var vegetation_data = tile_data.get_custom_data_by_layer_id(0)
	var isOccupied = tile_data.get_custom_data_by_layer_id(1)
	var isWall = tile_data.get_custom_data_by_layer_id(2)
	var tileColor = tile_data.modulate
	
	tileTable.tile_data = tile_data
	tileTable.tile_pos = tile_pos
	tileTable.vegetation_data = vegetation_data
	tileTable.isOccupied = isOccupied
	tileTable.isWall = isWall
	tileTable.tileColor = tileColor
	return tileTable
	
func lerpPosition(obj, target, dur = 1.0, start = null):
	var t = 0.0
	if start:
		obj.position = start
	
	while t < 1.0:
		obj.position = lerp(obj.position, target, t)
		t += get_process_delta_time() / dur
		await(get_tree().create_timer(get_process_delta_time()).timeout)
		
		if obj.position.distance_to(target) <= 1:
			break
			
	obj.position = target
	if health <= 0:
		die()

func lerpSize(obj, target, dur = 1.0, start = null): #maybe just merge the lerp funcs into one but idc
	var t = 0.0
	if start:
		obj.scale = start
	
	while t < 1.0:
		obj.scale = lerp(obj.scale, target, t)
		t += get_process_delta_time() / dur
		await(get_tree().create_timer(get_process_delta_time()).timeout)
		
		if obj.scale.x <= (target - obj.scale).x + 0.4 :
			break
	obj.scale = target
	
func mutate(obj, oldGene):
	var size = genotypes.size()
	var selectedgene = genotypes.keys()[randi() % size]
	if selectedgene == oldGene:
		mutate(obj, oldGene)
		return
	obj.genotype = selectedgene
	
func createChild(pos, otherParent): #really really really should clean this up at some point. proably modularize it for other traits too
	if otherParent.canBreed == false:
		return
	var child = duplicate()
	
	for i in child.get_children():
		if i is RayCast2D:
			i.queue_free()
	
	hunger -= (maxHunger * 0.4)
	canBreed = false
	child.position = pos
	child.hunger = (child.maxHunger / 5)
	child.health = 1
	child.canBreed = false
	child.isChild = true
	child.get_node("TurnCooldown").stop()
	child.genotype = str(genotype[randi_range(0, 1)], otherParent.genotype[randi_range(0, 1)])
	if randi_range(1, 25) > 24: # mutation
		mutate(child, child.genotype)
		
	
	if child.genotype == "bB":
		child.genotype = "Bb"
	
	get_parent().add_child(child)
	$BebeCooldown.start()
	
# we could possibly improve performance by mapping out the "worth" a tile has on a specific instance, 
# and getting that instead of each instance computing its own best path. would also allow for something lie A*
# but i barely know what that is and im lazy and this is a bio project wtf am i saying
func roam_func(): 
	if isHiding: return
	visRate = 0.0
	var possibleMoves := [
		Vector2(position.x + 16, position.y),
		Vector2(position.x - 16, position.y),
		Vector2(position.x, position.y + 16),
		Vector2(position.x, position.y - 16),
		
		Vector2(position.x - 16, position.y - 16),
		Vector2(position.x + 16, position.y - 16),
		Vector2(position.x - 16, position.y + 16),
		Vector2(position.x + 16, position.y + 16)
		]
	
	possibleMoves.shuffle()
	var selectedTile = null
	
	for i in possibleMoves:
		var tile_data = findVegetationData(i) # turns table of the tile passed
		var veggie_data = tile_data.get("vegetation_data")
		var isOccupied = tile_data.get("isOccupied")
		var isWall = tile_data.get("isWall")
		var tileColor = tile_data.get("tileColor")
		
		if not isWall and veggie_data == -1 and shouldHide:
			visRate = compColor(tileColor) * 100
			selectedTile = i
			isHiding = true
			setOccupied(true)
			
			return
			
		var lookAtTile = RayCast2D.new() # VISION RAYCASTS
		lookAtTile.collide_with_areas = true
		lookAtTile.target_position = (i - global_position)
		lookAtTile.set_collision_mask_value(2, true)
		add_child(lookAtTile)
		lookAtTile.exclude_parent = false
		await get_tree().create_timer(0.01).timeout
		
		if lookAtTile.get_collider() != null and lookAtTile.get_collider().get_parent() is plant: # EAT BUSHES
			var Plant = lookAtTile.get_collider().get_parent() as plant
			Plant.consume()
			
			hunger = clamp(hunger + 20, 0, maxHunger)
			updateMeter(hungerMeter, hunger, maxHunger)
			if health < 3:
				heal()
		
		if canBreed: # BREEDING
			if lookAtTile.is_colliding() and (hunger >= maxHunger * 0.45) and lookAtTile.get_collider().get_parent() is burd:
				var childTile = null
				
				for childPos in possibleMoves:
					var isChildTileOccupied = findVegetationData(childPos).get("isOccupied")
					if isChildTileOccupied == false:
						childTile = childPos
						break
				if childTile != null:
					var otherParentCol = lookAtTile.get_collider() as Area2D
					if otherParentCol == null: return # rare crash occurs without this check, should probably protect against it in most if not all cases
					var otherParent = otherParentCol.get_parent() as burd
					createChild(childTile, otherParent)
					
		
		
		lookAtTile.queue_free()
			
		
			
		if veggie_data == null or isOccupied:
			continue
			
		
		
		if selectedTile == null or veggie_data > findVegetationData(selectedTile).get("vegetation_data"): #if we dont have a selected tile, or if the growth on this tile is better thna the one on the next tile
			selectedTile = i
	var currentTile  = findVegetationData(position)
	var currentVeggie = currentTile.get("vegetation_data")
	var selTileInfo = findVegetationData(selectedTile)
	
	if selectedTile and selTileInfo.get("isOccupied"):
		roam_func()
		return
	
	turnTimer.start()
	if selectedTile == null: #EARLY RETURNS
		return	
	elif currentVeggie != 0 and selectedTile == null:
		return
	setOccupied(true, selectedTile)
	setOccupied(false, position)
	await lerpPosition(self, selectedTile, 0.5)
	turnTimer.start()
	
	
func consume():
	var currentTile = findVegetationData(position)
	var currentVeggie = currentTile.get("vegetation_data")
	if currentVeggie == null: return
	var desiredVeggie = tile_coords[currentVeggie - 1]
	if currentVeggie <= 0: return
	tile.set_cell(0, currentTile.get("tile_pos"), 1, desiredVeggie)
	
	hunger = clamp(hunger + (metabolism * 0.3), 0, maxHunger)
	updateMeter(hungerMeter, hunger, maxHunger)
	if health < 3 and hunger >= (maxHunger * 0.9):
		heal()
	
func die():
	setOccupied(false)
	lerpSize($Sprite2D, Vector2(0,0))
	queue_free()
	
func hurt(dmg = 1):
	animator.play("hurt")
	health -= dmg
	updateMeter(hpMeter, health, maxHealth)
		
func heal(amt = 1):
	health += amt
	updateMeter(hpMeter, health, maxHealth)
	if health > maxHealth:
		health = maxHealth

func updateMeter(meter : ProgressBar, numerator, denominator):
	if meter.visible == true:
		meter.max_value = denominator
		meter.value = numerator
	
func _ready() -> void:
	WorldNode.timeChanged.connect(Callable(self, "onTimeChange"))
	if not isChild: #on ready, randomize the genepool
		var size = genotypes.size()
		var selectedgene = genotypes.keys()[randi() % size]
		genotype = selectedgene
	else:
		$BebeCooldown.start()
	$Sprite2D.modulate = genotypes.get(genotype)
	updateMeter(hpMeter, health, maxHealth)
	updateMeter(hungerMeter, hunger, maxHunger)
	$TurnCooldown.start(metabolism)
	
	setOccupied(true, position)
	
	var birdCount = 0
	for i in get_parent().get_children():
		birdCount += 1
	name = str("Burd", birdCount)
	
func _on_turn_cooldown_timeout() -> void:
	if hunger <= 0:
		hurt()
	
	
	if hunger < (maxHunger * 0.8):
		consume()
		
	turnsTilHunger += 1
	
	roam_func()
	if turnsTilHunger < (5 / metabolism): #early return, only triggers after n turns
		return
	
	turnsTilHunger = 0
	
	hunger = clamp(hunger - ((metabolism * 0.5)), 0, maxHunger)
	updateMeter(hungerMeter, hunger, maxHunger)


func _on_bebe_cooldown_timeout() -> void:
	canBreed = true

func onTimeChange(time):
	if time > 0:
		shouldHide = true
	else:
		turnTimer.start()
		shouldHide = false
		isHiding = false


func _on_body_mouse_entered() -> void:
	lerpSize($Sprite2D, Vector2(1, 1), 0.3, Vector2(0.8, 0.8))


func _on_body_mouse_exited() -> void:
	lerpSize($Sprite2D, Vector2(0.8, 0.8), 0.3)


func _on_body_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("MousePrimary"):
		clicked.emit()
