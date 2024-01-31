extends Control

var burdCount = 0
@onready var burdContainer = $"/root/World/birds"
@onready var text = $RichTextLabel as RichTextLabel

func updateBurdCount():
	$RichTextLabel.text = str("burd count:", burdCount)
	
func _ready() -> void:
	burdContainer.connect("child_entered_tree", Callable(self, "addBird"))
	burdContainer.connect("child_exiting_tree", Callable(self, "removeBird"))
	_on_force_update_timeout()

func addBird(node: Node) -> void:
	if node is burd:
		burdCount += 1
		updateBurdCount()

func _on_force_update_timeout() -> void:
	var count = 0
	for i in burdContainer.get_children():
		count += 1
	burdCount = count
	updateBurdCount()


func removeBird(node: Node) -> void:
	if node is burd:
		burdCount -= 1
		updateBurdCount()
		
func _process(delta: float) -> void:
	text.scroll_to_line(0) #this is bad but theres no other way to diable scrolling in richtext LMFAO
