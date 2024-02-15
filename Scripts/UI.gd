extends CanvasLayer

@onready var menuBurd = $Menu/MenuBurd/TextureRect as TextureRect
@onready var menuBurd2 = $Menu/MenuBurd2/TextureRect as TextureRect
@onready var menuBurdTimer = $Timer as Timer
@onready var title = $Menu/Title as RichTextLabel

@export var newScene : PackedScene

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

var count = 0 # make the sprite inverting sync with the music
func _on_timer_timeout() -> void:
	count += 1
	if count >= 3:
		menuBurdTimer.wait_time = 0.5
		count = 0
	else:
		menuBurdTimer.wait_time = 0.75
	
	menuBurd.flip_h = not menuBurd.flip_h
	menuBurd2.flip_h = not menuBurd2.flip_h
	var rand = randf_range(0.8, 1.3)
	lerpSize(title, Vector2(rand, rand), 0.1)

func burdClicked(obj):
	await lerpSize(obj, Vector2(1.3, 1.3), 0.1, Vector2(1.2, 1.2))
	lerpSize(obj, Vector2(1.2, 1.2), 0.1)
	obj.rotation += PI/180
	
func mouseEnter(obj):
	lerpSize(obj, Vector2(1.2, 1.2), 0.3)
	
func mouseExit(obj):
	lerpSize(obj, Vector2(1, 1), 0.3)
	
	
 #this is marginally better than doing it manually
#originally the burd buttons just did it localized within themsleves but i wanted them to be all on the same tiemr
# and i  dint want to have to go up the tree for some reason
# so we have this
func _ready() -> void:
	menuBurd.get_parent().connect("pressed", Callable(self, "burdClicked").bind(menuBurd))
	menuBurd.connect("mouse_entered", Callable(self, "mouseEnter").bind(menuBurd))
	menuBurd.connect("mouse_exited", Callable(self, "mouseExit").bind(menuBurd))
	
	menuBurd2.get_parent().connect("pressed", Callable(self, "burdClicked").bind(menuBurd2))
	menuBurd2.connect("mouse_entered", Callable(self, "mouseEnter").bind(menuBurd2))
	menuBurd2.connect("mouse_exited", Callable(self, "mouseExit").bind(menuBurd2))



func _on_credits_pressed() -> void:
	$Credits.visible = true
	$Menu.visible = false


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(newScene)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_button_2_pressed() -> void:
	$Credits.visible = false
	$Menu.visible = true
