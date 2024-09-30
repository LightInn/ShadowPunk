extends Control

signal choice_made(index)
signal dialogue_advanced

@onready var choices_container: VBoxContainer = $Panel/MarginContainer/ChoicesContainer

func _ready():
	pass

func display_dialogue(dialogue: Dictionary):
	print(dialogue)
	
	# Gérer les choix
	for child : Button in choices_container.get_children():
		child.release_focus()
		child.queue_free()
	
	await get_tree().process_frame
	
	if dialogue.type == "choice":
		choices_container.show()
		for i in range(dialogue.choices.size()):
			var choice = dialogue.choices[i]
			var button = Button.new()
			button.text = choice.text
			print(choice)
			button.pressed.connect(_on_choice_button_pressed.bind(i))
			choices_container.add_child(button)
		
		var first : Button = choices_container.get_child(0)
		first.grab_focus()
			
		
		
	else:
		choices_container.hide()

func _on_choice_button_pressed(index: int):
	choice_made.emit(index)

func _on_next_button_pressed():
	dialogue_advanced.emit()
