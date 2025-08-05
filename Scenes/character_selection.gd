extends Control

@export var available_characters: Array[CharacterData]
@onready var character_name: Label = $VBoxContainer2/CharacterName
@onready var reset_button: Button = $MarginContainer/VBoxContainer/reset_button

const MAX_PARTY_SIZE = 4
var selected_party: Array[CharacterData] = []

@onready var available_container = $MarginContainer/VBoxContainer/HBoxContainer/AvailableCharacters
@onready var selected_slots = [
$MarginContainer/VBoxContainer/HBoxContainer2/SelectedParty/PartySlot1,
$MarginContainer/VBoxContainer/HBoxContainer2/SelectedParty/PartySlot2,
$MarginContainer/VBoxContainer/HBoxContainer2/SelectedParty/PartySlot3, 
$MarginContainer/VBoxContainer/HBoxContainer2/SelectedParty/PartySlot4
]
@onready var confirm_button: Button = $MarginContainer/VBoxContainer/confirm_button

func _ready():
	populate_available_characters()
	update_party_slots()

func populate_available_characters():
	for char in available_characters:
		var button = TextureButton.new()
		button.texture_normal = char.icon
		button.tooltip_text = char.name
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		button.custom_minimum_size = Vector2(96, 96)
		button.connect("pressed", func(): on_character_selected(char))
		available_container.add_child(button)

func on_character_selected(char: CharacterData):
	if selected_party.has(char):
		return
	if selected_party.size() >= MAX_PARTY_SIZE:
		return
	selected_party.append(char)
	update_party_slots()

func update_party_slots():
	for i in range(MAX_PARTY_SIZE):
		if i < selected_party.size():
			selected_slots[i].texture = selected_party[i].icon
			character_name.text = selected_party[i].name
		else:
			selected_slots[i].texture = null

	confirm_button.disabled = selected_party.size() != MAX_PARTY_SIZE

func _on_confirm_button_pressed() -> void:
	Global.player_party = selected_party.duplicate()
	#get_tree().change_scene_to_file("res://Scenes/battle_scene.tscn")
	get_tree().change_scene_to_file("res://Scenes/overworld.tscn")

func _on_reset_button_pressed() -> void:
	selected_party.clear()
	character_name.text = ""
	for slot in selected_slots:
		slot.texture = null
