extends Camera2D
var oldMousePos = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	oldMousePos = get_viewport().get_mouse_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("CameraDrag"):
		var newMousePos = get_viewport().get_mouse_position()
		position -= (newMousePos - oldMousePos).normalized() * clamp(2 * (4.5 / zoom.x), 3, 10)
		oldMousePos = newMousePos
		
	if Input.is_action_just_pressed("CameraZoomIn") and zoom.x < 5:
		zoom += Vector2(0.5, 0.5)
	elif Input.is_action_just_pressed("CameraZoomOut"):
		zoom -= Vector2(0.5, 0.5)
