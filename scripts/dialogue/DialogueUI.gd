extends Control

signal choice_made(index)
signal dialogue_advanced

@onready var speaker_name: Label = $Panel/MarginContainer/VBoxContainer/SpeakerName
@onready var dialogue_text: Label = $Panel/MarginContainer/VBoxContainer/DialogueText
@onready var choices_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ChoicesContainer
@onready var next_button: Button = $Panel/MarginContainer/VBoxContainer/NextButton

func _ready():
	next_button.pressed.connect(_on_next_button_pressed)

func display_dialogue(dialogue: Dictionary):
	print(dialogue)
	speaker_name.text = dialogue.speaker
	dialogue_text.text = dialogue.text
	
	# Gérer les choix
	for child in choices_container.get_children():
		child.queue_free()
	
	if dialogue.type == "choice":
		next_button.hide()
		choices_container.show()
		for i in range(dialogue.choices.size()):
			var choice = dialogue.choices[i]
			var button = Button.new()
			button.text = choice.text
			print(choice)
			button.pressed.connect(_on_choice_button_pressed.bind(i))
			choices_container.add_child(button)
	else:
		next_button.show()
		choices_container.hide()

func _on_choice_button_pressed(index: int):
	choice_made.emit(index)

func _on_next_button_pressed():
	dialogue_advanced.emit()
