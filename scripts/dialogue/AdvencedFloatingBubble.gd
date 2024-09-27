extends Node3D
class_name DialogueBubble

signal animation_finished
signal choice_made(choice_index: int)

@onready var viewport = $SubViewport
@onready var nine_patch_rect = $SubViewport/Bubble/NinePatchRect
@onready var label = $SubViewport/Bubble/Content/Body/Message/Label
@onready var speaker_label = $SubViewport/Bubble/Content/Header/SpeakerLabel
@onready var speaker_icon = $SubViewport/Bubble/Content/Header/SpeakerIcon
@onready var next_indicator = $SubViewport/Bubble/Content/Body/Message/NextIndicator
@onready var choice_container = $SubViewport/Bubble/Content/ChoiceContainer
@onready var sprite = $Sprite3D

@export var vertical_offset: float = 2.0
@export var max_width: float = 300.0
@export var padding: Vector2 = Vector2(10, 10)

var _target: Node3D
var _player: Node3D
var _dialogue_character: Node

var current_size: Vector2 = Vector2.ZERO
var _target_size: Vector2 = Vector2.ZERO
var resize_speed: float = 10.0

var _current_text: String = ""
var _target_text: String = ""
var char_speed: float = 0.05
var space_speed: float = 0.025
var punctuation_speed: float = 0.1

func _ready():
	hide()
	next_indicator.hide()

func init(dialogue : Dictionary, npc: RigidBody3D, player: Player, dialogue_character: Node):
	_target = player if dialogue.speaker == "player" else npc
	_player = player
	_dialogue_character = dialogue_character
	set_speaker(dialogue.speaker)
	set_text(dialogue.text)
	if dialogue.type == "choice":
		setup_choices(dialogue.choices if "choices" in dialogue else [])
	show_bubble()

func _process(delta):
	if not is_visible():
		return

	update_size(delta)
	update_position()
	update_visibility()
	update_text_animation(delta)

func set_speaker(speaker: String):
	speaker_label.text = speaker.capitalize()
	# Vous devrez implémenter une logique pour définir l'icône du speaker
	# Par exemple : speaker_icon.texture = load("res://path/to/icons/" + speaker + ".png")

func set_text(new_text: String):
	_target_text = new_text
	_current_text = ""
	label.text = ""
	next_indicator.hide()

func update_size(delta):
	current_size = current_size.lerp(_target_size, resize_speed * delta)
	viewport.size = current_size
	nine_patch_rect.size = current_size

func update_position():
	if _target:
		global_transform.origin = _target.global_transform.origin + Vector3.UP * vertical_offset

func update_visibility():
	if not _player or not _target:
		return

	var to_player = _player.global_position - global_position
	var distance = to_player.length()
	var is_visible = distance <= _dialogue_character.max_dialogue_distance

	if is_visible != visible:
		if is_visible:
			show_bubble()
		else:
			hide_bubble()

func update_text_animation(delta):
	if _current_text.length() < _target_text.length():
		var next_char = _target_text[_current_text.length()]
		_current_text += next_char
		label.text = _current_text
		
		var wait_time
		if next_char == " ":
			wait_time = space_speed
		elif next_char in [",", ".", "!", "?", ":", ";"]:
			wait_time = punctuation_speed
		else:
			wait_time = char_speed
		
		await get_tree().create_timer(wait_time).timeout
	elif _current_text == _target_text and not next_indicator.visible:
		next_indicator.show()

func show_bubble():
	if not visible:
		visible = true
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3.ONE, 0.3).from(Vector3.ZERO)
		tween.tween_callback(func(): animation_finished.emit())

func hide_bubble():
	if visible:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 0.3).from(Vector3.ONE)
		tween.tween_callback(func():
			visible = false
			animation_finished.emit()
		)

func setup_choices(choices: Array):
	if choices.is_empty():
		choice_container.hide()
		return

	choice_container.show()
	for child in choice_container.get_children():
		child.queue_free()

	for choice in choices:
		var button = Button.new()
		button.text = choice
		button.connect("pressed", func(): choice_made.emit(choice))
		choice_container.add_child(button)

func is_choice_bubble():
	return not choice_container.get_children().is_empty()
