extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var progress_bar: ProgressBar = $ProgressBar

@export var EnemyStats: EntityStats

func _ready() -> void:
	progress_bar.value = EnemyStats.Health
	animation.play("spawn")
	sprite.texture = EnemyStats.sprite

func _process(delta: float) -> void:
	progress_bar.value = EnemyStats.Health
	
func play_damage_anim():
	animation.play("damaged")
	
func play_attack_anim():
	animation.play("attack")

func play_death_anim():
	animation.play("death")
