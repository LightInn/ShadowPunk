extends MeshInstance3D

@export var billboard_count : int = 100
@export var billboard_scene : PackedScene
@export var spread : float = 0.5

func _ready():
	generate_billboards()

func generate_billboards():
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.instance_count = billboard_count
	multimesh.mesh = billboard_scene.instantiate().mesh
	
	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = multimesh
	add_child(mmi)
	
	var mesh_aabb = get_aabb()
	
	for i in range(billboard_count):
		var position = Vector3.ZERO
		var found_valid_position = false
		
		while not found_valid_position:
			position = Vector3(
				randf_range(mesh_aabb.position.x, mesh_aabb.end.x),
				randf_range(mesh_aabb.position.y, mesh_aabb.end.y),
				randf_range(mesh_aabb.position.z, mesh_aabb.end.z)
			)
			
			if mesh_aabb.has_point(position):
				found_valid_position = true
		
		var transform = Transform3D().translated(position)
		multimesh.set_instance_transform(i, transform)
		
		# Convertir la position Vector3 en Color
		var color_data = Color(position.x, position.y, position.z, 1.0)
		multimesh.set_instance_custom_data(i, color_data)
