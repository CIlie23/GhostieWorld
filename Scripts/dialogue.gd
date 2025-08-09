extends Control

@onready var title: Label = $VBoxContainer/Name
@onready var dialogue: RichTextLabel = $VBoxContainer/Dialogue
#@onready var ok_button: Button = $Box/okButton
@onready var type_writer_effect: AnimationPlayer = $AnimationPlayer
@onready var bossPortrait: TextureRect = $TextureRect

func _ready() -> void:
	type_writer_effect.play("typewriter")
	
func display_line(line : String, speaker : String = "", bossIcon : Texture = null):
	bossPortrait.texture = bossIcon
	title.visible = (speaker != "")
	title.text = speaker
	dialogue.text = line
	type_writer_effect.play("typewriter") #https://www.youtube.com/watch?v=jWDrNAbps7Q
	
func close_dialogue():
	visible = false

func open_dialogue():
	visible = true
	
func _on_ok_button_pressed() -> void:
	print("Hello")
	close_dialogue()

func _on_type_writer_effect_animation_finished(anim_name: StringName) -> void:
	pass
	#ok_button.grab_focus() # Focus the OK button after typing finishes
