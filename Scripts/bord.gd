extends Node
class_name bord

@onready var danger = $Danger as Sprite2D
@onready var collisionArea = $Area2D as Area2D
@onready var pivot = $Pivot as Node2D
@onready var path = $Path2D as Path2D
@onready var pathFollow = $Path2D/PathFollow2D as PathFollow2D
@onready var WorldNode = $"/root/World" as world
@onready var tile = WorldNode.find_child("TileMap") as TileMap
@onready var timer = $AttackTimer as Timer

var shouldAttack = false

func _ready() -> void:
	WorldNode.timeChanged.connect(Callable(self, "onTimeChange"))
	toggleBordVisibility(false)
	$Pivot/AnimatedSprite2D.play()
	timer.wait_time = randi_range(20, 50)

func lerpPosition(obj, target, start = null, dur = 1.0):
	var t = 0.0
	if start:
		obj.position = start
	
	while t < 1.0:
		obj.position = lerp(obj.position, target, t)
		t += get_process_delta_time() / dur
		await(get_tree().create_timer(get_process_delta_time()).timeout)
		
		if obj.position.distance_to(target) <= 1:
			break

func hunt():
	for i in collisionArea.get_overlapping_areas():
		var burdTarget = i.get_parent() as burd
		var chance = 0.0
		
		if burdTarget.isHiding:
			chance = burdTarget.visRate
		
		if randf_range(0, 100) >= chance:
			burdTarget.die()
			
	
func toggleBordVisibility(val):
	pivot.visible = val	
	danger.visible = val

func pickTarget():
	var target
	var tileTable = tile.get_used_cells(0).duplicate()
	tileTable.shuffle()
	for i in tileTable:
		var isWall = tile.get_cell_tile_data(0, i).get_custom_data_by_layer_id(2)
		if isWall == false:
			target = tile.map_to_local(i)
			break
	collisionArea.position = target
	path.position = target
	danger.position = target


func _on_attack_timer_timeout() -> void:
	if shouldAttack == false:
		return
	pickTarget()
	
	var start = Vector2(pathFollow.position.x - 5000, pathFollow.position.y - 5000)
	var target = pathFollow.position
	
	
	
	toggleBordVisibility(true)
	lerpPosition(pivot, start, target, 5.0)
	
	var pt = 0.0
	var pdur = 1.0
	var shouldHunt = true # to prevent loops of hunt()
	pathFollow.progress_ratio = 0
	while pt < 1.0:
		pt += get_process_delta_time() / pdur
		pathFollow.progress_ratio = pt
		pivot.position = path.to_global(pathFollow.position)
		pivot.rotation = pathFollow.rotation
		
		if pathFollow.progress_ratio >= 0.3 and pathFollow.progress_ratio <= 0.35 and shouldHunt:
			hunt()
			shouldHunt = false
		await(get_tree().create_timer(get_process_delta_time()).timeout)
	toggleBordVisibility(false)

	

	timer.wait_time = randi_range(10, 20)
	timer.start()
	
func onTimeChange(time):
	if time == 2:
		shouldAttack = true
		timer.wait_time = randi_range(5, 25)
		timer.start()
	elif timer.is_stopped() == false:
		shouldAttack = false
		timer.stop()
	else:
		timer.stop()
		shouldAttack = false
