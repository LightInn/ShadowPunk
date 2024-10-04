extends RigidBody3D


@onready var DC = $DialogueCharacter;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact(player : Player) -> void:
	player.interact_freeze()
	DC.interact(player)
