extends Node3D

@onready var prevBurd = $"3DBURD" as RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prevBurd.rotate(Vector3.UP, randi())
	prevBurd.rotate(Vector3.RIGHT, randi())
	prevBurd.constant_torque = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))

func customizeBurd(color):
	prevBurd.change_color(color)


func _on_timer_timeout() -> void:
	prevBurd.constant_torque = Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5))
