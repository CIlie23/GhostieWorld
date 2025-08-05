extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@export var PlayerStats: EntityStats
@onready var health_bar: ProgressBar = $VBoxContainer/HBoxContainer/HealthBar
@onready var mana_bar: ProgressBar = $VBoxContainer/HBoxContainer2/ManaBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.play("popIn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health_bar.value = PlayerStats.Health
	mana_bar.value = PlayerStats.Mana

func play_attack_anim():
	animation.play("attack")

func play_damaged_anim():
	animation.play("damaged")
