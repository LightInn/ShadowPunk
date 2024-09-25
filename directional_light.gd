extends DirectionalLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_label_pressed(KEY_LEFT):
		self.rotate(Vector3(.1,1,0).normalized(),.2*delta)
	if Input.is_key_label_pressed(KEY_RIGHT):
		self.rotate(Vector3(.1,1,0).normalized(),-.2*delta)
	pass
