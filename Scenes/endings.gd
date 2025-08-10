extends Node2D
@onready var texture_rect: TextureRect = $TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.isJeffAlive == true && Global.isMaskAlive == true:
		texture_rect.texture = preload("res://Assets/Endings/endingOne.png")
	elif Global.isJeffAlive == false && Global.isMaskAlive == true:
		texture_rect.texture = preload("res://Assets/Endings/endingTwo.png")
	elif Global.isJeffAlive == true && Global.isMaskAlive == false:
		texture_rect.texture = preload("res://Assets/Endings/endingFour.png")
	elif Global.isJeffAlive == false && Global.isMaskAlive == false:
		texture_rect.texture = preload("res://Assets/Endings/endingThree.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
