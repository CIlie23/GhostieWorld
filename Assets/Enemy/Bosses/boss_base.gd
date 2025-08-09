extends Node2D

@onready var animation: AnimationPlayer = $Animation
@export var BossStats: EntityStats
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	sprite.texture = BossStats.sprite
	print("This is a test boss")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func chooseOption():
	var optionArray:Array = ["option1", "option2", "option3"]
	var possibleActions = optionArray.pick_random()
	
	match possibleActions:
		"option1":
			print("Attack one!")
			animation.play("attackOne")
		"option2":
			print("Attack two!")
			animation.play("attackTwo")
		"option3":
			print("Attack tree!")
			animation.play("attackThree")

func play_dead_anim():
	animation.play("Dead")
