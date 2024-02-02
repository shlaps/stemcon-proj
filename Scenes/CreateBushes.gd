extends Node

@export var bushScene : PackedScene
@export var maxBushes = 7

func _ready() -> void:
	var count = 1
	while count <= maxBushes:
		count += 1
		newBush()

func newBush():
	var bushCopy = bushScene.instantiate() as plant
	add_child.call_deferred(bushCopy)
	bushCopy.connect("tree_exiting", Callable(self, "newBush"))
