extends Node

@onready var base = $Sprite2D as Sprite2D #tile its on
@onready var comparer = $Sprite2D2 as Sprite2D #organsim color
@onready var Indicator = $Sprite2D3 as Sprite2D


func compColor(): #WE FUCKING DID IT LADS!!!!!!!!!
	var colorBase = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	var colorComparer = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	var invisRate = 0
	
	base.modulate = colorBase	
	comparer.modulate = colorComparer
	
	
	var CompColor = colorBase - colorComparer
	CompColor.r = abs(CompColor.r)
	CompColor.g = abs(CompColor.g)
	CompColor.b = abs(CompColor.b)
	
	invisRate += 1 - CompColor.r
	invisRate += 1 - CompColor.g
	invisRate += 1 - CompColor.b
	
	invisRate /= 3
	invisRate = pow(invisRate, 2.5)
	print(invisRate)
	
	CompColor.a = 1

func _ready() -> void:
	compColor()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause_game"):
		compColor()
