extends CharacterBody3D

class_name Player

@export var speed = 5.0
@export var jump_force = 4.5
@export var interaction_distance = 2.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $Camera
@onready var interaction_area = $InteractiveArea

var is_interaction_frozen : bool = false

func _ready():
	# Fixer la rotation de la caméra à un angle isométrique
	#camera.rotation_degrees = Vector3(-30, 45, 0)
	pass
	

func _physics_process(delta):
	# Appliquer la gravité
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var input_dir = Vector2(0,0)
	
	if not is_interaction_frozen : 
		# Gérer le saut
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_force
		# Obtenir la direction d'entrée
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Calculer la direction en fonction de la caméra
	var camera_basis = camera.global_transform.basis
	var direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction.y = 0  # S'assurer que le mouvement est horizontal
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	# Vérifier les interactions
	if Input.is_action_just_pressed("interact"):
		print("E")
		interact()
	if Input.is_key_label_pressed(KEY_ESCAPE):
		get_tree().quit()
		

func interact_freeze():
	is_interaction_frozen = true

func interact_unfreeze():
	is_interaction_frozen = false
	


		
		
		
func interact():
	var interactables = interaction_area.get_overlapping_bodies()
	for body in interactables:
		if body.is_in_group("interactive"):
			var dialogue_component = body.get_node("DialogueComponent")
			if dialogue_component :
				dialogue_component.interact(self)
				break  # Interagir seulement avec le premier NPC à portée
