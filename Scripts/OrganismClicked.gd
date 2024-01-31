extends CanvasLayer
@onready var WorldNode = $"/root/World" as Node2D
@onready var birds = WorldNode.find_child("birds") as Node

@onready var BurdInfo = $BurdInfo as Control
@onready var BurdText = $BurdInfo/RichTextLabel as RichTextLabel

func gotClicked(obj : burd):
	print("yo")
	BurdText.text = str(obj.name, "'s genotype: ", obj.genotype)
	BurdInfo.visible = true

func _ready() -> void:
	for node in birds.get_children():
		connectBurd(node)
	
	birds.connect("child_entered_tree", Callable(self, "connectBurd"))
	BurdInfo.visible = false
	visible = true

func connectBurd(node: Node) -> void:
	if node is burd:
		print("burd")
		node.connect("clicked", Callable(self, "gotClicked").bind(node))


func _on_button_pressed() -> void:
	BurdInfo.visible = false
