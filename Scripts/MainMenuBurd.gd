extends RigidBody3D

@export var shouldDestroy = true
@onready var Colorers = $Colorers

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if shouldDestroy:
		queue_free()

func _ready() -> void:
	if shouldDestroy:
		change_color(null)

func _on_timer_timeout() -> void:
	if shouldDestroy:
		queue_free()

func change_color(color):
	var material = Colorers.get_children()[0].get_active_material(0) as StandardMaterial3D # get first mesh in colorer's obj, since they all share the same material in the scene
	
	if color == null:
		material.albedo_color = Color(randf_range(1, 255) / 255, randf_range(1, 255)/ 255, randf_range(1, 255) / 255, 1)
		return
	
	material.albedo_color = color
