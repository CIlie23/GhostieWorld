extends Node2D

@onready var enemy: Node2D = $Enemy
@onready var kullix: Node2D = $CharacterInBattle
@onready var gui_text: Sprite2D = $GUIText
@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var hud: Control = $HUD/AttackButtons
@onready var health_bar: ProgressBar = $HUD/Portrait/VBoxContainer/HBoxContainer/HealthBar
@onready var mana_bar: ProgressBar = $HUD/Portrait/VBoxContainer/HBoxContainer2/ManaBar

@onready var btn_attack: Button = $HUD/AttackButtons/VBoxContainer/Attack
@onready var btn_health: Button = $HUD/AttackButtons/VBoxContainer/Health

#var ChosenMonster = 1
var CurrentTurn = "Player"
var isEnemyDying: bool = false
var isStunned: bool = false
var isPlayerStunned:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_anims()
	randomize()
	chosemonster()

func play_anims():
	animation.play("empty")
	await get_tree().create_timer(1.0).timeout
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#PLACEHOLDER
	if Input.is_key_pressed(KEY_SHIFT):
		get_tree().change_scene_to_file("res://Scenes/overworld.tscn")
		
	#print("Current mana: ", kullix.PlayerStats.Mana)
	health_bar.value = kullix.PlayerStats.Health
	mana_bar.value = kullix.PlayerStats.Mana
	update_buttons()
	if not isEnemyDying and enemy.EnemyStats.Health <= 0:
		isEnemyDying = true
		switch_overworld()

func update_buttons():
	btn_attack.disabled = kullix.PlayerStats.Mana < 2
	btn_health.disabled = kullix.PlayerStats.Mana < 1

func switch_overworld():
	enemy.play_death_anim()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/overworld.tscn")

# ----------------------- BUTTONS ------------------------------------

func _on_attack_pressed() -> void:
	kullix.PlayerStats.Mana -= 2
	update_buttons()
		
	hud.visible = false
	animation.play("camera_enemy")
	await animation.animation_finished

	if randf() < kullix.PlayerStats.CritChance:
		animation.play("crit")
		enemy.EnemyStats.take_damage(kullix.PlayerStats.Attack * 2)
	elif randf() < kullix.PlayerStats.MissChance:
		animation.play("miss")
	elif randf() < kullix.PlayerStats.StunChance:
		#print("Enemy Stun")
		animation.play("stun")
		enemy.EnemyStats.take_damage(kullix.PlayerStats.Attack + 2)
		isStunned = true
	else:
		enemy.EnemyStats.take_damage(kullix.PlayerStats.Attack)
	
	kullix.play_attack_anim()
	enemy.play_damage_anim()
	print("enemy died")
	await get_tree().create_timer(0.5).timeout
	switch_turn()

func _on_health_pressed() -> void:
	kullix.PlayerStats.Mana -= 1
	update_buttons()
		
	animation.play("HealPlayer")
	kullix.PlayerStats.Health += 2
	#print("Healed!: ", kullix.PlayerStats.Health )
	await get_tree().create_timer(0.5).timeout
	animation.play("camera_enemy")
	switch_turn()
		
#func _on_change_pressed() -> void:
	#print("pressed")
	##ChosenMonster = 2
	#chosemonster()

func _on_defense_pressed() -> void:
	kullix.PlayerStats.Mana -= 1
	update_buttons()
	kullix.PlayerStats.Mana += 3
	kullix.PlayerStats.Defense += 5
	animation.play("DefensePlayer")
	await animation.animation_finished
	animation.play("camera_enemy")
	switch_turn()
	
# ---------------------------------------------------------------

func switch_turn():
	if CurrentTurn == "Monster":
		if isPlayerStunned == true:
			#animation.play("stun_player")
			#await animation.animation_finished
			#print("Player is stunned")
			MonsterTurn()
			animation.play("camera_enemy")
			isPlayerStunned = false

		await get_tree().create_timer(0.5).timeout
		kullix.PlayerStats.Mana += 1
		animation.play("ManaPlayer")
		CurrentTurn = "Player"
		hud.visible = true
	elif CurrentTurn == "Player":
		hud.visible = false
		await get_tree().create_timer(0.5).timeout
		CurrentTurn = "Monster"
		
		MonsterTurn()

func MonsterTurn():
	if enemy.EnemyStats.Health <= 0:
		return
	if isStunned == true:
		switch_turn()

		animation.play("camera_player")
		isStunned = false
		return

	var monsterActions: Array = ["attack", "heal", "defend"]
	var possibleActions = monsterActions.pick_random()

	match possibleActions:
		"attack": # FIX TS
			animation.play("camera_player")
			#print("camera moved, we should fix this")
			await animation.animation_finished
			
			if randf() < enemy.EnemyStats.CritChance:
				animation.play("crit_player")
				await animation.animation_finished
				#print("player got critted")
				kullix.PlayerStats.take_damage(enemy.EnemyStats.Attack * 2)
			elif randf() < enemy.EnemyStats.MissChance:
				#print("enemy attack missed")
				animation.play("miss_player")
				await animation.animation_finished
			elif randf() < enemy.EnemyStats.StunChance:
				animation.play("stun_player")
				await animation.animation_finished
				#print("player got stunned!")
				kullix.PlayerStats.take_damage(enemy.EnemyStats.Attack + 2)
				isPlayerStunned = true
			else:
				#print("attack")
				#animation.play("camera_player")
				await get_tree().create_timer(0.3).timeout
				kullix.PlayerStats.take_damage(enemy.EnemyStats.Attack)
				enemy.play_attack_anim()
			#animation.play("camera_player")
			await get_tree().create_timer(0.5).timeout
			switch_turn()
		"heal":
			#print("heal")
			enemy.EnemyStats.Health += 1
			animation.play("HealEnemy")
			await animation.animation_finished
			animation.play("camera_player")
			await get_tree().create_timer(0.5).timeout
			switch_turn()
		"defend":
			#print("defend")
			enemy.EnemyStats.Defense += 1
			animation.play("DefenseEnemy")
			await animation.animation_finished
			animation.play("camera_player")
			await get_tree().create_timer(0.5).timeout
			switch_turn()
			
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
