extends Node3D
class_name DialogueBubble

signal choice_made(choice_index: int)

@onready var viewport = $SubViewport
@onready var bubble = $SubViewport/Bubble
@onready var sprite = $Sprite3D
@onready var label = $SubViewport/Bubble/Content/Body/Message/Label
@onready var speaker_label = $SubViewport/Bubble/Content/Header/SpeakerLabel

const BubbleUI = preload("res://HUD/Dialogue/bubble.tscn")

var target_size := Vector2.ZERO
var current_size := Vector2.ZERO
var current_text := ""
var target_text := ""
var target_position := Vector3.ZERO
var _text_timer := 0.0
var _current_char_index := 0

@export var vertical_offset := 2.0
@export var MOVING_SPEED := 5.0
@export var MAX_WIDE_SIZE := 450.0
@export var text_speed := 0.015
@export var space_speed := 0.03
@export var special_speed := 0.1

var player : Node3D

func _ready():
	hide_bubble()
	initialize_size()

func _process(delta):
	update_size(delta)
	update_text(delta)
	update_position(delta)

func set_player(player_node : Node3D):
	player = player_node

func set_dialogue(dialogue: Dictionary):
	speaker_label.text = dialogue.speaker
	target_text = dialogue.text
	reset_text_animation()
	calculate_target_size(dialogue)

func show_bubble(position : Vector3):
	target_position = position
	if not visible:
		animate_visibility(true)

func hide_bubble():
	if visible:
		animate_visibility(false)

# Private methods

func initialize_size():
	current_size = Vector2.ZERO
	viewport.size = current_size
	bubble.size = current_size
	sprite.pixel_size = 0.01

func update_size(delta):
	current_size = current_size.lerp(target_size, 5.0 * delta)
	update_label_wrap()
	update_viewport_and_bubble_size()

func update_label_wrap():
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if target_text.length() > 30 else TextServer.AUTOWRAP_OFF

func update_viewport_and_bubble_size():
	viewport.size = current_size + Vector2(8, 8)
	bubble.size = current_size
	bubble.get_node("Background").custom_minimum_size = current_size

func update_text(delta):
	if _current_char_index < target_text.length():
		_text_timer += delta
		var current_char = target_text[_current_char_index]
		var char_speed = get_char_speed(current_char)
		
		if _text_timer >= char_speed:
			_text_timer -= char_speed
			current_text += current_char
			label.text = current_text
			_current_char_index += 1

func get_char_speed(char: String) -> float:
	if char == " ":
		return space_speed
	elif char in [".", ",", "!", "?", ":", ";", "-"]:
		return special_speed
	else:
		return text_speed

func update_position(delta):
	sprite.position = sprite.position.lerp(target_position, MOVING_SPEED * delta)
	sprite.position.y = vertical_offset

func calculate_target_size(dialogue: Dictionary):
	var temp_bubble = BubbleUI.instantiate()
	add_child(temp_bubble)
	var temp_label = temp_bubble.get_node("Content/Body/Message/Label")
	
	setup_temp_label(temp_label, dialogue)
	
	await get_tree().process_frame
	
	target_size = temp_bubble.size
	remove_child(temp_bubble)
	temp_bubble.queue_free()

func setup_temp_label(temp_label: Label, dialogue: Dictionary):
	temp_label.custom_minimum_size = Vector2.ZERO
	temp_label.text = target_text
	
	if target_text.length() > 30:
		temp_label.custom_minimum_size.x = MAX_WIDE_SIZE
		temp_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func reset_text_animation():
	current_text = ""
	_current_char_index = 0
	_text_timer = 0.0
	label.text = current_text

func animate_visibility(show: bool):
	var tween = create_tween()
	var target_alpha = 1.0 if show else 0.0
	tween.tween_property(sprite, "modulate:a", target_alpha, 0.3).from(1.0 - target_alpha)
	if not show:
		tween.tween_callback(set_visible.bind(false))
	else:
		visible = true
