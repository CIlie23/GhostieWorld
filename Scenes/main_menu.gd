extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	animation.play("fadeOut")
	await animation.animation_finished
	get_tree().change_scene_to_file("res://Assets/Enemy/Bosses/MaskTutorial/boss_battle_scene.tscn")
