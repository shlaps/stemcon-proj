extends TextureButton

@export var offset = Vector2(0, 2) #remember y axis in 2D is "inversed"

@onready var textLabel = $RichTextLabel as RichTextLabel
@onready var upPos = textLabel.position
@onready var downPos = upPos + offset

func _on_button_down() -> void:
	textLabel.position = downPos


func _on_button_up() -> void:
	textLabel.position = upPos

func _process(delta: float) -> void: #womp womp
	textLabel.scroll_to_line(0)


func _on_mouse_exited() -> void:
	textLabel.position = upPos
