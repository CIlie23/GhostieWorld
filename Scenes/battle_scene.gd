extends Node2D

@onready var enemy: Node2D = $Enemy
@onready var kullix: Node2D = $CharacterInBattle
@onready var gui_text: Sprite2D = $GUIText
@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var hud: CanvasLayer = $HUD
#@export var PlayerStats: EntityStats

#var ChosenMonster = 1
var CurrentTurn = "Player"
var isEnemyDying: bool = false
var isStunned: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Health: ", kullix.PlayerStats.Health)
	animation.play("empty")
	randomize()
	chosemonster()
	print("Battle started!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not isEnemyDying and enemy.EnemyStats.Health <= 0:
		isEnemyDying = true
		switch_overworld()
		
func switch_overworld():
	enemy.play_death_anim()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/overworld.tscn")
	
func _on_attack_pressed() -> void:
	if randf() < kullix.PlayerStats.CritChance:
		print("CRITICAL HUIT!")
		animation.play("crit")
		enemy.EnemyStats.take_damage(kullix.PlayerStats.Attack * 2)
	else:
		enemy.EnemyStats.take_damage(kullix.PlayerStats.Attack)
	
	kullix.play_attack_anim()
	enemy.play_damage_anim()
	await get_tree().create_timer(0.5).timeout
	switch_turn()

func _on_health_pressed() -> void:
	kullix.PlayerStats.Health += 1
	print("Healed!: ", kullix.PlayerStats.Health )
	switch_turn()

func switch_turn():
	if CurrentTurn == "Monster":
		animation.play("camera_player")
		await get_tree().create_timer(0.5).timeout
		CurrentTurn = "Player"
		hud.visible = true
	elif CurrentTurn == "Player":
		hud.visible = false
		animation.play("camera_enemy")
		await get_tree().create_timer(0.5).timeout
		CurrentTurn = "Monster"
		
		MonsterTurn()

func MonsterTurn():
	if enemy.EnemyStats.Health <= 0:
		return
	else:
		await get_tree().create_timer(0.3).timeout
		#kullix.PlayerStats.Health -= (enemy.EnemyStats.Attack - kullix.PlayerStats.Defense)
		kullix.PlayerStats.take_damage(enemy.EnemyStats.Attack)
		enemy.play_attack_anim()
		print("Kullix health: ", kullix.PlayerStats.Health)
	await get_tree().create_timer(0.5).timeout
	switch_turn()


#------------------------------------------------------------------------
#
#------------------------------------------------------------------------
func chosemonster():
	var ChosenMonster = [1, 2, 3].pick_random()
	if ChosenMonster == 1:
		enemy.EnemyStats = load("res://Assets/Enemy/EnemyResources/bug/bug.tres")
	elif ChosenMonster == 2:
		enemy.EnemyStats = load("res://Assets/Enemy/EnemyResources/dummy/dummy.tres")
	elif ChosenMonster == 3:
		enemy.EnemyStats = load("res://Assets/Enemy/EnemyResources/shroom/shroom.tres")

	var sprite_node = enemy.get_node("Sprite2D") 
	sprite_node.texture = enemy.EnemyStats.sprite

		
func _on_change_pressed() -> void:
	print("pressed")
	#ChosenMonster = 2
	chosemonster()
