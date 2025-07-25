extends Control

@onready var player_party_container: VBoxContainer = $PlayerParty
@onready var enemy_party: VBoxContainer = $EnemyParty
@onready var action_menu: Control = $ActionMenu

@onready var attack_buttons = action_menu.get_node("VBoxContainer").get_children()

var selected_character_panel: Control = null
var character_panels: Array = []
var current_character_index: int = 0


func _ready():
	spawn_player_party()
	action_menu.visible = false

func spawn_player_party():
	for data in Global.player_party:
		var panel_scene = preload("res://Scenes/character_in_battle.tscn")
		var panel = panel_scene.instantiate()
		player_party_container.add_child(panel) 
		panel.call_deferred("setup", data)
		character_panels.append(panel)


func _on_character_ready(panel):
	selected_character_panel = panel
	action_menu.visible = true
	show_attack_options(panel.character_data.attacks)

func show_attack_options(attacks):
	for i in range(attack_buttons.size()):
		var button = attack_buttons[i]

		# Disconnect all previous connections manually
		for conn in button.get_signal_connection_list("pressed"):
			button.disconnect("pressed", conn.callable)

		if i < attacks.size():
			button.text = attacks[i].name
			button.visible = true
			button.connect("pressed", func(): _on_attack_pressed(attacks[i]))
		else:
			button.visible = false


func _on_attack_pressed(attack):
	# For now we'll just print the name and reset cooldown
	print("Used attack: ", attack.name)
	selected_character_panel.reset_cooldown()
	action_menu.visible = false
	
	current_character_index = (current_character_index + 1) % character_panels.size()
	try_start_turn()

#func _on_character_in_battle_ready_to_act(character_panel: Variant) -> void:
	#selected_character_panel = character_panel
	#action_menu.visible = true
	#show_attack_options(character_panel.character_data.attacks)

func try_start_turn():
	var tried = 0
	while tried < character_panels.size():
		var panel = character_panels[current_character_index]
		if panel.can_act:
			selected_character_panel = panel
			action_menu.visible = true
			show_attack_options(panel.character_data.attacks)
			return
		tried += 1
		current_character_index = (current_character_index + 1) % character_panels.size()

	# If none are ready then do nuffin
	action_menu.visible = false
	selected_character_panel = null

func _on_timer_2_timeout() -> void:
	if selected_character_panel == null:
		try_start_turn()
