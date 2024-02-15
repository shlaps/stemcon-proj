extends CanvasLayer
@onready var WorldNode = $"/root/World" as Node2D
@onready var birds = WorldNode.find_child("birds") as Node

@onready var BurdInfo = $BurdInfo as Control
@onready var BurdGenotypeText = $BurdInfo/Info
@onready var BurdNameText = $BurdInfo/Name
@onready var PauseMenu = $Menu
@onready var counters = $BirdCounter/Counters as Control

@export var burdPreviewScene : PackedScene
@export var mainMenuScene : PackedScene

@onready var subViewport = $BurdInfo/SubViewportContainer/SubViewport


#birdcount stuff
var burdCount = 0
@onready var burdContainer = $"/root/World/birds"

func seperateNumbers(num :int):
	var numString = str(num)
	var returnTable = []
	if numString.length() < 3:
		numString = str("0", numString)
	elif numString.length() > 3:
		returnTable = ["?", "?", "?"]
		return returnTable
	
	for i in numString.length():
		returnTable.append(numString[i])
	return returnTable

func  _process(delta: float) -> void:
	$BirdCounter/MenuButton.rotation += PI/180

func updateBurdCount(): #changes text to match that of the population
	var popCount = seperateNumbers(burdCount)
	var maxNumber = popCount.size()
	var count = 0
	for i : RichTextLabel in counters.get_children():
		if count >= maxNumber:
			i.text = "0"
			continue
		
		i.text = popCount[count]
		count += 1

func addBird(node: Node) -> void: #on child add of burd node in world scene
	if node is burd:
		burdCount += 1
		updateBurdCount()

func _on_force_update_timeout() -> void: # fix any desycns, if they occur
	var count = 0
	for i in burdContainer.get_children():
		count += 1
	burdCount = count
	updateBurdCount()


func removeBird(node: Node) -> void: # on child remove of burd node in world scene
	if node is burd:
		burdCount -= 1
		updateBurdCount()

func _ready() -> void:
	burdContainer.connect("child_entered_tree", Callable(self, "addBird"))
	burdContainer.connect("child_exiting_tree", Callable(self, "removeBird"))
	_on_force_update_timeout()
	#end of bird count
	
	for node in birds.get_children():
		connectBurd(node)
	
	birds.connect("child_entered_tree", Callable(self, "connectBurd"))
	BurdInfo.visible = false
	visible = true
	
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


func gotClicked(obj : burd): # update burd info window on clicking an organism
	BurdGenotypeText.text = ""
	for i in obj.genotype:
		BurdGenotypeText.text = str(BurdGenotypeText.text, i)
	BurdNameText.text = str(obj.name)
	BurdInfo.visible = true
	for i in subViewport.get_children():
		i.queue_free()
	var newPreviewScene = burdPreviewScene.instantiate() 
	subViewport.add_child(newPreviewScene)
	newPreviewScene.customizeBurd(obj.genotypes.get(obj.genotype))
	lerpPosition(BurdInfo, Vector2(0, 0))
	
	

func connectBurd(node: Node) -> void:
	if node is burd:
		node.connect("clicked", Callable(self, "gotClicked").bind(node))


func _on_button_pressed() -> void:
	await lerpPosition(BurdInfo, Vector2(0, 135))
	BurdInfo.visible = false

func _on_continue_pressed() -> void:
	PauseMenu.visible = false
	Engine.time_scale = 1

func _on_quit_pressed() -> void:
	print("!!!!!")
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func _on_pause_pressed() -> void:
	if Engine.time_scale > 1:
		Engine.time_scale = 1
	elif Engine.time_scale == 1:
		Engine.time_scale = 0


func _on_menu_button_pressed() -> void:
	Engine.time_scale = 0
	PauseMenu.visible = true

func illegalAction(obj):
	obj.modulate = Color.RED
	await(get_tree().create_timer(.3).timeout)
	obj.modulate = Color.WHITE
	await(get_tree().create_timer(.3).timeout)
	obj.modulate = Color.RED
	await(get_tree().create_timer(.3).timeout)
	obj.modulate = Color.WHITE


func _on_speed_up_pressed() -> void:
	if Engine.time_scale <= 4:
		Engine.time_scale += 1
	else:
		illegalAction($BirdCounter/SpeedUp)


func _on_speed_down_pressed() -> void:
	if Engine.time_scale > 0:
		Engine.time_scale -= 1
