#extends Node
#
#class_name DialogueCharacter
#
#var DM : DialogueManager
#@export_file("*.json") var dialogue_file: String
#@onready var dialogue_ui = $DialogueUI
#@onready var floating_bubble = $AdvancedFloatingBubble
#@export var bubble_height : float = 2.0
#
#
#var player : Player
#
#func set_player(player_node : Player):
	#player = player_node
	#floating_bubble.set_player(player)
#
## call when NPC is spawned
#func _ready():
	#DM = DialogueManager.new()
	#if dialogue_file:
		#DM.load_dialogue(dialogue_file)
	#
	##floating_bubble.vertical_offset = bubble_height
	#
	## Connect signals
	#dialogue_ui.choice_made.connect(_on_choice_made)
	#dialogue_ui.dialogue_advanced.connect(_dialogue_next)
#
#func start_dialogue():
	#DM.reset_dialogue()
	#var dialogue = DM.get_current_dialogue()
	#set_player(player)
	#display_dialogue(dialogue)
#
#func display_dialogue(dialogue: Dictionary):
	##dialogue_ui.display_dialogue(dialogue)
	##dialogue_ui.show()
	#
	#if dialogue.type == "dialogue":
		#floating_bubble.set_text(dialogue.text)
		#floating_bubble.show_bubble()
	#elif dialogue.type == "choice":
		#floating_bubble.set_text(dialogue.text)
		#floating_bubble.show_bubble()
	#else:
		#floating_bubble.hide_bubble()
#
#func _dialogue_next():
	#DM.advance_dialogue()
	#var dialogue = DM.get_current_dialogue()
	#if dialogue.is_empty():
		#end_dialogue()
	#else:
		#display_dialogue(dialogue)
##
#func _on_choice_made(choice_index: int):
	#DM.make_choice(choice_index)
	#_dialogue_next()
#
#func end_dialogue():
	#DM.end_dialogue()
	#dialogue_ui.hide()
	#floating_bubble.hide_bubble()
#
#func interact(player : Player):
	#if DM.is_dialogue_finished():
		#start_dialogue()
	#else : 
		#_dialogue_next()
	#
	## check si deja demarer, continuer, sinon demarrer.
	#
	#
extends Node
class_name DialogueCharacter

const BubbleScene = preload("res://HUD/Dialogue/AdvFloatingBubble.tscn")

@export_file("*.json") var dialogue_file: String
@export var max_dialogue_distance: float = 5.0

var DM: DialogueManager
var _player: Player
var current_bubble: DialogueBubble = null
var last_bubble: DialogueBubble = null

func _ready():
	DM = DialogueManager.new()
	if dialogue_file:
		DM.load_dialogue(dialogue_file)
	else :
		push_error("NO DIALOGUE FILE LOADED")

func set_player(player_node: Player):
	_player = player_node

func interact(player: Player):
	print("dialogue interation >")
	set_player(player)
	if DM.is_dialogue_finished():
		start_dialogue()
	else:
		dialogue_next()

func start_dialogue():
	print("start dialogue")
	DM.reset_dialogue()
	var dialogue = DM.get_current_dialogue()
	display_dialogue(dialogue)

func dialogue_next():
	print("next")
	DM.advance_dialogue()
	var dialogue = DM.get_current_dialogue()
	if dialogue.is_empty():
		end_dialogue()
	else:
		display_dialogue(dialogue)

func display_dialogue(dialogue: Dictionary):
	
	if last_bubble : 
		last_bubble.hide_bubble()
		await last_bubble.animation_finished
		last_bubble.queue_free()
	
	last_bubble = current_bubble

	var new_bubble: DialogueBubble = BubbleScene.instantiate()
	add_child(new_bubble)
	
	new_bubble.init(dialogue, owner, _player, self)

	if dialogue.type == "choice":
		current_bubble = new_bubble
	else:
		current_bubble = new_bubble

	if dialogue.type == "end":
		await new_bubble.animation_finished
		end_dialogue()

func end_dialogue():
	DM.end_dialogue()
	if current_bubble:
		current_bubble.hide_bubble()
		await current_bubble.animation_finished
		current_bubble.queue_free()
		current_bubble = null

func on_choice_made(choice_index: int):
	DM.make_choice(choice_index)
	if current_bubble.is_choice_bubble():
		current_bubble.hide_bubble()
		await current_bubble.animation_finished
		current_bubble.queue_free()
		current_bubble = null
	dialogue_next()
