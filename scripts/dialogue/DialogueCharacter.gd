extends Node

class_name DialogueCharacter

var DM : DialogueManager
@export_file("*.json") var dialogue_file: String
@onready var dialogue_ui = $DialogueUI
@onready var floating_bubble = $DialogueBubble
@export var bubble_height : float = 2.0


var player : Player

func set_player(player_node : Player):
	player = player_node
	floating_bubble.set_player(player)

# call when NPC is spawned
func _ready():
	DM = DialogueManager.new()
	if dialogue_file:
		DM.load_dialogue(dialogue_file)
	get_parent().add_to_group("interactive")
	
	floating_bubble.vertical_offset = bubble_height
	
	# Connect signals
	dialogue_ui.choice_made.connect(_on_choice_made)
	dialogue_ui.dialogue_advanced.connect(_dialogue_next)

func start_dialogue():
	DM.reset_dialogue()
	var dialogue = DM.get_current_dialogue()
	display_dialogue(dialogue)

func display_dialogue(dialogue: Dictionary):
	dialogue_ui.display_dialogue(dialogue)
	dialogue_ui.show()
	
	if dialogue.type == "dialogue" or dialogue.type == "choice":
		
		var target : Node3D = player if dialogue.speaker == "player" else get_parent();
		
		floating_bubble.set_dialogue(dialogue)
		floating_bubble.show_bubble(target.position)

	else:
		end_dialogue()

func _dialogue_next():
	DM.advance_dialogue()
	var dialogue = DM.get_current_dialogue()
	if dialogue.is_empty():
		end_dialogue()
	else:
		display_dialogue(dialogue)

func _on_choice_made(choice_index: int):
	DM.make_choice(choice_index)
	var dialogue = DM.get_current_dialogue()
	display_dialogue(dialogue)

func end_dialogue():
	print("END DIALOGUE HERE")
	DM.end_dialogue()
	dialogue_ui.hide()
	floating_bubble.hide_bubble()
	player.interact_unfreeze()

func interact(player : Player):
	set_player(player)
	player.interact_freeze()
	if DM.is_dialogue_finished():
		start_dialogue()
	else : 
		var current = DM.get_current_dialogue()
		if  current.type == "choice" :
			return
		_dialogue_next()
	
	# check si deja demarer, continuer, sinon demarrer.
	
	
