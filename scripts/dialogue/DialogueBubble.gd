extends Node3D
class_name DialogueBubble

signal choice_made(choice_index: int)

@onready var viewport = $SubViewport
@onready var nine_patch_rect = $SubViewport/Bubble/Background
@onready var bubble = $SubViewport/Bubble
@onready var sprite = $Sprite3D
@onready var pointer_sprite = $Sprite3D/PointerSprite3D

@onready var label = $SubViewport/Bubble/Content/Body/Message/Label
@onready var speaker_label = $SubViewport/Bubble/Content/Header/SpeakerLabel
@onready var speaker_icon = $SubViewport/Bubble/Content/Header/SpeakerIcon
@onready var next_indicator = $SubViewport/Bubble/Content/Body/Message/NextIndicator

var target_size : Vector2
var current_size : Vector2
var resize_speed : float = 5.0
var writing_speed : float = 20.0
var current_text : String = ""
var target_text : String = ""
var target_position : Vector3 = Vector3(0,0,0)
var _text_timer: float = 0.0
var _current_char_index: int = 0

@export var vertical_offset : float = 2.0
@export var max_visibility_distance : float = 10.0
@export var min_visibility_distance : float = 1.0
@export var visibility_angle : float = 60.0  # En degrés
@export var MOVING_SPEED : float = 5.0

@export var text_speed: float = 0.015  # Vitesse pour les caractères normaux
@export var space_speed: float = 0.03  # Vitesse pour les espaces
@export var special_speed: float = 0.1  # Vitesse pour les caractères spéciaux

var player : Node3D  # Référence au joueur


func _ready():
	current_size = Vector2(0, 0)
	viewport.size = current_size
	sprite.pixel_size = 0.01  # Ajustez selon vos besoins
	update_position(target_position)

func set_player(player_node : Node3D):
	player = player_node

func _process(delta):
		# Animer le redimensionnement
	current_size = current_size.lerp(target_size, resize_speed * delta)
	viewport.size = current_size
	nine_patch_rect.custom_minimum_size = current_size
	
	# Appeler la nouvelle fonction d'animation de texte
	update_text(delta)
	
	var new_position = lerp(sprite.position, target_position, MOVING_SPEED * delta)
	update_position(new_position)
	#update_visibility()s

func update_text(delta: float):
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


func update_position(position : Vector3):
	sprite.position = position
	sprite.position.y = vertical_offset
	pointer_sprite.position.y = vertical_offset - (current_size.y * sprite.pixel_size / 2)

func update_visibility():
	if not player:
		return
	
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	# Vérifier la distance
	if distance > max_visibility_distance or distance < min_visibility_distance:
		hide_bubble()
		return
	
	# Vérifier l'angle
	var forward = -global_transform.basis.z
	var angle = rad_to_deg(forward.angle_to(to_player))
	if angle > visibility_angle / 2:
		hide_bubble()
		return
	
	# Si on arrive ici, la bulle devrait être visible
	show_bubble(target_position)
	
	# Ajuster l'opacité en fonction de la distance
	var opacity = 1.0 - (distance - min_visibility_distance) / (max_visibility_distance - min_visibility_distance)
	sprite.modulate.a = opacity
	pointer_sprite.modulate.a = opacity

func show_bubble(position : Vector3):
	
	target_position = position
	
	if not visible:
		visible = true
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 1.0, 0.3).from(0.0)
		tween.parallel().tween_property(pointer_sprite, "modulate:a", 1.0, 0.3).from(0.0)

func hide_bubble():
	if visible:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.parallel().tween_property(pointer_sprite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(set_visible.bind(false))





func set_dialogue(dialogue: Dictionary):
	
	if dialogue.type == "choice":
		setup_choices(dialogue.choices if "choices" in dialogue else [], bubble)
	
	
	speaker_label.text = dialogue.speaker
	target_text = dialogue.text
	current_text = ""
	_current_char_index = 0
	_text_timer = 0.0
	
	calculate_target_size(dialogue)
	# Réinitialiser le texte pour l'animation
	label.text = current_text
	
	



func calculate_target_size(dialogue: Dictionary):
	
	# Créer un label temporaire pour calculer la taille
	var temp_bubble = bubble.duplicate()
	
	
	# Size id not updated if not visible
	#temp_bubble.visible = false
	
	temp_bubble.size_flags_horizontal = 4
	temp_bubble.size_flags_vertical = 4
	
	self.add_child(temp_bubble)
	temp_bubble.get_node("Content/Body/Message/Label").text = target_text
	temp_bubble.get_node("Background").custom_minimum_size = Vector2(0,0)
	if dialogue.type == "choice":
		setup_choices(dialogue.choices if "choices" in dialogue else [], temp_bubble)
	
	await get_tree().process_frame
	
	target_size = temp_bubble.size;
	remove_child(temp_bubble)
	temp_bubble.queue_free()
	


func setup_choices(choices: Array, bubble : Container, real : bool):
	
	var choice_container = bubble.get_node("Content/ChoiceContainer")
	
	if choices.is_empty():
		choice_container.hide()
		return

	
	for child in choice_container.get_children():
		child.queue_free()
	
	
	for choice in choices:
		var button = Button.new()
		button.text = choice.text
		button.connect("pressed", func(): choice_made.emit(choice))
		choice_container.add_child(button)
		
	choice_container.show()
	await get_tree().process_frame
	
