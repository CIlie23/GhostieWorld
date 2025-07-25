extends Control

var character_data: CharacterData
var cooldown: float = 0
var max_cooldown: float = 3.0
var can_act := false
var current_hp: int = 100  # Placeholder

signal ready_to_act(character_panel)

@onready var charIcon: TextureRect = $Icon
@onready var bar: ProgressBar = $ProgressBar
@onready var hp_label: Label = $HP
#@onready var charIcon: Sprite2D = $Sprite2D

func _ready() -> void:
	print("charIcon =", charIcon)

func setup(data: CharacterData):
	character_data = data
	if !charIcon:
		push_error("charIcon is null")
		return
	charIcon.texture = data.icon

	cooldown = 0
	can_act = false
	current_hp = 100
	#hp_label.text = "HP: %d" % current_hp

func _process(delta):
	if can_act:
		return
	cooldown += delta
	bar.value = cooldown / max_cooldown * 100.0
	if cooldown >= max_cooldown:
		can_act = true
		emit_signal("ready_to_act", self)

func reset_cooldown():
	cooldown = 0
	can_act = false
