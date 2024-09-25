extends Node3D

@onready var viewport = $SubViewport
@onready var nine_patch_rect = $SubViewport/Bubble/NinePatchRect
@onready var label = $SubViewport/Bubble/MarginContainer/Label
@onready var sprite = $Sprite3D
@onready var pointer_sprite = $PointerSprite3D

var target_size : Vector2
var current_size : Vector2
var resize_speed : float = 5.0
var writing_speed : float = 20.0
var current_text : String = ""
var target_text : String = ""
@export var vertical_offset : float = 2.0
@export var max_visibility_distance : float = 10.0
@export var min_visibility_distance : float = 1.0
@export var visibility_angle : float = 60.0  # En degrés

var player : Node3D  # Référence au joueur


func _ready():
	current_size = Vector2(300, 200)
	viewport.size = current_size
	sprite.pixel_size = 0.01  # Ajustez selon vos besoins
	update_position()

func set_player(player_node : Node3D):
	player = player_node

func _process(delta):
		# Animer le redimensionnement
	current_size = current_size.lerp(target_size, resize_speed * delta)
	viewport.size = current_size
	nine_patch_rect.size = current_size
	
	# Animer l'écriture du texte
	if current_text.length() < target_text.length():
		var next_char_index = current_text.length()
		current_text += target_text[next_char_index]
		label.text = current_text
	
	update_position()
	update_visibility()

func update_position():
	sprite.position = owner.position
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
	show_bubble()
	
	# Ajuster l'opacité en fonction de la distance
	var opacity = 1.0 - (distance - min_visibility_distance) / (max_visibility_distance - min_visibility_distance)
	sprite.modulate.a = opacity
	pointer_sprite.modulate.a = opacity

func show_bubble():
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

func set_text(new_text: String):
	target_text = new_text
	current_text = ""
	
	# Calculer la taille cible
	label.text = new_text
	await get_tree().process_frame
	target_size = label.size + Vector2(50, 50)  # Ajouter de la marge
	
	# Réinitialiser le texte pour l'animation
	label.text = ""
