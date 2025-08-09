extends Node2D

@onready var enemy: Node2D = $TestBoxx
@onready var kullix: Node2D = $CharacterInBattle
@onready var gui_text: Sprite2D = $GUIText
@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var hud: Control = $HUD/AttackButtons
@onready var health_bar: ProgressBar = $HUD/Portrait/VBoxContainer/HBoxContainer/HealthBar
@onready var mana_bar: ProgressBar = $HUD/Portrait/VBoxContainer/HBoxContainer2/ManaBar

@onready var btn_attack: Button = $HUD/AttackButtons/VBoxContainer/Attack
@onready var btn_health: Button = $HUD/AttackButtons/VBoxContainer/Health
@onready var btn_defense: Button = $HUD/AttackButtons/VBoxContainer/Defense
@onready var btn_spare: Button = $HUD/AttackButtons/VBoxContainer/Spare
@onready var btn_kill: Button = $HUD/AttackButtons/VBoxContainer/Kill

@onready var text_box: Control = $HUD/DialogueBox

@onready var dialogue_box: Control = $HUD/DialogueBox
@onready var boss_progres_bar: ProgressBar = $HUD/ProgressBar

@export var mask_dialogue: BossDialogue
@onready var otherAnimations: AnimationPlayer = $Spare

@onready var victoryScreen: Control = $HUD/Victory
@onready var cash_label: RichTextLabel = $HUD/Victory/HBoxContainer/RichTextLabel

var CurrentTurn = "Player"
var isEnemyDying: bool = false
var isStunned: bool = false
var isPlayerStunned:bool = false
var isSparing: bool = false

var ActionSequences: Array = ["Fighting", "Healing","Choice", "Spare", "Kill"]
var chosenAction 

func play_intro():
	for line in mask_dialogue.intro_lines:
		dialogue_box.display_line(line, mask_dialogue.boss_name, mask_dialogue.boss_icon)
		await text_box.type_writer_effect.animation_finished
		await get_tree().create_timer(1.0).timeout
	awesome_sequence(ActionSequences[0])
	
func play_hurt():
	for line in mask_dialogue.hurt_lines:
		dialogue_box.display_line(line, mask_dialogue.boss_name, mask_dialogue.boss_icon)
		await text_box.type_writer_effect.animation_finished
		await get_tree().create_timer(1.0).timeout
	awesome_sequence(ActionSequences[2])

func play_spare():
	otherAnimations.play("Yippe")
	for line in mask_dialogue.spared_lines:
		dialogue_box.display_line(line, mask_dialogue.boss_name, mask_dialogue.boss_icon)
		await text_box.type_writer_effect.animation_finished
		await get_tree().create_timer(1.0).timeout

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/overworld.tscn")
	
func play_kill():
	otherAnimations.play("victoryScreen")
	Global.cash += 10
	cash_label.text = "[rainbow]+" + str(10) + "[/rainbow]"

func awesome_sequence(chosenAction): #for fighting
	match chosenAction:
		"Fighting":
			dialogue_box.close_dialogue()
			btn_attack.visible = true	
		"Healing":
			btn_attack.visible = false	
			dialogue_box.open_dialogue()
			play_hurt()
		"Choice":
			isSparing = true
			dialogue_box.close_dialogue()
			#btn_kill.visible = true
			btn_attack.visible = true
			btn_spare.visible = true
		"Spare":
			#btn_kill.visible = false
			btn_attack.visible = false
			btn_spare.visible = false
			dialogue_box.open_dialogue()
			play_spare()
		"Kill":
			btn_kill.visible = false
			btn_spare.visible = false
			play_kill()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_box.visible = true
	enemy.BossStats = load("res://Assets/Enemy/Bosses/MaskTutorial/mask_boss.tres")
		
	play_intro()
	
	var sprite_node = enemy.get_node("Sprite2D") 
	sprite_node.texture = enemy.BossStats.sprite
	
	play_anims()
	randomize()

func play_anims():
	animation.play("empty")
	await get_tree().create_timer(1.0).timeout
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boss_progres_bar.value = enemy.BossStats.Health
	health_bar.value = kullix.PlayerStats.Health
	mana_bar.value = kullix.PlayerStats.Mana
	update_buttons()
	
	if not isEnemyDying and enemy.BossStats.Health <= 0:
		isEnemyDying = true
		switch_overworld()

func update_buttons():
	btn_attack.disabled = kullix.PlayerStats.Mana < 2
	btn_health.disabled = kullix.PlayerStats.Mana < 1

func switch_overworld():
	enemy.play_dead_anim()
	await get_tree().create_timer(1.0).timeout
	play_kill()
	print ("Global.cash: " + str(Global.cash))
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/overworld.tscn")

# ----------------------- BUTTONS ------------------------------------

func _on_attack_pressed() -> void:
	kullix.PlayerStats.Mana -= 2
	update_buttons()
		
	hud.visible = false
	animation.play("camera_enemy")
	await animation.animation_finished
	
	if isSparing == true:
		kullix.PlayerStats.Attack = 1000
		kullix.PlayerStats.MissChance = 0
		
	if randf() < kullix.PlayerStats.CritChance:
		animation.play("crit")
		enemy.BossStats.take_damage(kullix.PlayerStats.Attack * 2)
	elif randf() < kullix.PlayerStats.MissChance:
		animation.play("miss")
	#elif randf() < kullix.PlayerStats.StunChance:
		##print("Enemy Stun")
		#animation.play("stun")
		#enemy.BossStats.take_damage(kullix.PlayerStats.Attack + 2)
		#isStunned = true
	else:
		enemy.BossStats.take_damage(kullix.PlayerStats.Attack)
	
	kullix.play_attack_anim()
	#enemy.play_damage_anim()
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
		
func _on_defense_pressed() -> void:
	kullix.PlayerStats.Mana -= 1
	update_buttons()
	kullix.PlayerStats.Mana += 3
	kullix.PlayerStats.Defense += 5
	animation.play("DefensePlayer")
	await animation.animation_finished
	animation.play("camera_enemy")
	switch_turn()

func _on_spare_pressed() -> void:
	awesome_sequence(ActionSequences[3])

func _on_kill_pressed() -> void:
	awesome_sequence(ActionSequences[4])
# ---------------------------------------------------------------

func switch_turn():
	if CurrentTurn == "Monster":
		if isPlayerStunned == true:
			MonsterTurn(monsterActions[3])
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
		
		MonsterTurn(monsterActions[3])

var monsterActions: Array = ["attack", "heal", "defend", "doNothing"]
var possibleActions

func MonsterTurn(possibleActions):
		
	if enemy.BossStats.Health <= 0:
		return
	if isStunned == true:
		switch_turn()

		animation.play("camera_player")
		isStunned = false
		return

	#var possibleActions = monsterActions.pick_random()

	match possibleActions:
		"attack": 
			animation.play("camera_player")
			await animation.animation_finished
			
			enemy.chooseOption()
			
			if randf() < enemy.BossStats.CritChance:
				animation.play("crit_player")
				await animation.animation_finished
				kullix.PlayerStats.take_damage(enemy.BossStats.Attack * 2)
			elif randf() < enemy.BossStats.MissChance:
				animation.play("miss_player")
				await animation.animation_finished
			elif randf() < enemy.BossStats.StunChance:
				animation.play("stun_player")
				await animation.animation_finished
				kullix.PlayerStats.take_damage(enemy.BossStats.Attack + 2)
				isPlayerStunned = true
			else:
				await get_tree().create_timer(0.3).timeout
				kullix.PlayerStats.take_damage(enemy.BossStats.Attack)

			await get_tree().create_timer(0.5).timeout
			switch_turn()
		"heal":
			#print("heal")
			enemy.BossStats.Health += 1
			animation.play("HealEnemy")
			await animation.animation_finished
			animation.play("camera_player")
			await get_tree().create_timer(0.5).timeout
			switch_turn()
		"defend":
			#print("defend")
			enemy.BossStats.Defense += 1
			animation.play("DefenseEnemy")
			await animation.animation_finished
			animation.play("camera_player")
			await get_tree().create_timer(0.5).timeout
			switch_turn()
		"doNothing":
			animation.play("camera_player")
			await get_tree().create_timer(0.5).timeout
			switch_turn()
			awesome_sequence(ActionSequences[1])

#------------------------------------------------------------------------
func chosemonster():
	var ChosenMonster = [1, 2, 3].pick_random()
	if ChosenMonster == 1:
		enemy.BossStats = load("res://Assets/Enemy/EnemyResources/bug/bug.tres")
	elif ChosenMonster == 2:
		enemy.BossStats = load("res://Assets/Enemy/EnemyResources/dummy/dummy.tres")
	elif ChosenMonster == 3:
		enemy.BossStats = load("res://Assets/Enemy/EnemyResources/shroom/shroom.tres")

	var sprite_node = enemy.get_node("Sprite2D") 
	sprite_node.texture = enemy.BossStats.sprite
