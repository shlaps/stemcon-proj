extends Button

@onready var menuBurd = $TextureRect as TextureRect
@onready var menuBurdTimer = $TextureRect/Timer as Timer

var clickCount = 0
var syncCount = 0 

func lerpSize(obj, target, dur = 1.0, start = null): 
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

func _on_timer_timeout() -> void: # make the sprite inverting sync with the music
	syncCount += 1
	if syncCount >= 3:
		menuBurdTimer.wait_time = 0.5
		syncCount = 0
	else:
		menuBurdTimer.wait_time = 0.75
		
	
	menuBurd.flip_h = not menuBurd.flip_h

func _on_pressed() -> void:
	clickCount += 1
	await lerpSize(menuBurd, Vector2(1.3, 1.3), 0.1, Vector2(1.2, 1.2))
	lerpSize(menuBurd, Vector2(1.2, 1.2), 0.1)
	menuBurd.rotation += PI/180


func _on_mouse_entered() -> void:
	lerpSize(menuBurd, Vector2(1.2, 1.2), 0.3)


func _on_mouse_exited() -> void:
	lerpSize(menuBurd, Vector2(1, 1), 0.3)
