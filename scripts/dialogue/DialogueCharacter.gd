extends Node

class_name DialogueCharacter

var dialogue_manager : DialogueManager
@export_file("*.json") var dialogue_file: String
@onready var dialogue_ui = $DialogueUI
@onready var floating_bubble = $AdvancedFloatingBubble
@export var bubble_height : float = 2.0

var player : Player

func set_player(player_node : Player):
	player = player_node
	floating_bubble.set_player(player)

func _ready():
	dialogue_manager = DialogueManager.new()
	if dialogue_file:
		dialogue_manager.load_dialogue(dialogue_file)
	
	floating_bubble.vertical_offset = bubble_height
	
	# Connect signals
	dialogue_ui.choice_made.connect(_on_choice_made)
	dialogue_ui.dialogue_advanced.connect(_on_dialogue_advanced)

func start_dialogue():
	if dialogue_manager.is_dialogue_finished():
		dialogue_manager.reset_dialogue()
	var dialogue = dialogue_manager.get_current_dialogue()
	display_dialogue(dialogue)

func display_dialogue(dialogue: Dictionary):
	dialogue_ui.display_dialogue(dialogue)
	dialogue_ui.show()
	
	if dialogue.type == "dialogue":
		floating_bubble.set_text(dialogue.text)
		floating_bubble.show_bubble()
	else:
		floating_bubble.hide_bubble()

func _on_dialogue_advanced():
	dialogue_manager.advance_dialogue()
	var dialogue = dialogue_manager.get_current_dialogue()
	if dialogue.is_empty():
		end_dialogue()
	else:
		display_dialogue(dialogue)

func _on_choice_made(choice_index: int):
	dialogue_manager.make_choice(choice_index)
	_on_dialogue_advanced()

func end_dialogue():
	dialogue_manager.end_dialogue()
	dialogue_ui.hide()
	floating_bubble.hide_bubble()

func interact(player : Player):
	set_player(player)
	start_dialogue()
