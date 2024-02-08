extends Node3D

@export var burdModel : PackedScene
@onready var spawnPos = $"Marker3D"

func spawnModel():
	var modelsSpawned = randi_range(1, 5)
	var i = 1
	while i < modelsSpawned:
		var model = burdModel.instantiate() as RigidBody3D
		model.position = spawnPos.position + Vector3(randf_range(-5, 5),randf_range(-2, 5),randf_range(-5, 5))
		model.rotate(Vector3.UP, randf())
		model.rotate(Vector3.RIGHT, randf())
		add_child(model)
		i += 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnModel()
	$Timer.start()


func _on_timer_timeout() -> void:
	spawnModel()
	$Timer.wait_time = randf_range(0.25, 0.5)
	$Timer.start()
