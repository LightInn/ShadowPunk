extends Node

class_name DialogueManager

var dialogue_data: Dictionary
var current_node: String
var current_language: String = "en"


func load_dialogue(file_path: String):
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_content = file.get_as_text()
		var json_result = JSON.parse_string(json_content)
		if json_result != null:
			dialogue_data = json_result
			current_node = "end"
		else:
			print("Erreur de parsing JSON")
	else:
		print("Erreur : Fichier de dialogue non trouvé")

func get_current_dialogue() -> Dictionary:
	if not dialogue_data or not dialogue_data.has("nodes") or not dialogue_data["nodes"].has(current_node):
		return {}
	
	var node = dialogue_data["nodes"][current_node]
	var dialogue = {
		"type": node["type"],
		"speaker": node.get("speaker", ""),
		"text": node.get("text", {}).get(current_language, ""),
		"choices": []
	}
	
	if node["type"] == "choice":
		for choice in node["choices"]:
			dialogue["choices"].append({
				"text": choice["text"].get(current_language, ""),
				"next": choice["next"]
			})
	
	return dialogue

func make_choice(choice_index: int):
	var node = dialogue_data["nodes"][current_node]
	if node["type"] == "choice" and choice_index < node["choices"].size():
		current_node = node["choices"][choice_index]["next"]
	elif node.has("next"):
		current_node = node["next"]
	else:
		print("Dialogue terminé")

func advance_dialogue():
	var node = dialogue_data["nodes"][current_node]
	if node.has("next"):
		current_node = node["next"]
	else:
		print("Dont have a next node")

func set_language(language: String):
	if language in ["en", "fr"]:  # Ajoutez d'autres langues selon vos besoins
		current_language = language

func check_condition(condition: Dictionary) -> bool:
	# Implémentez ici la logique pour vérifier les conditions
	# Par exemple :
	if condition["type"] == "inventory_check":
		return check_inventory(condition["item"], condition["amount"])
	return true

func check_inventory(item: String, amount: int) -> bool:
	# Implémentez ici la vérification de l'inventaire
	# Ceci est juste un exemple, vous devrez l'adapter à votre système d'inventaire
	return true  # Pour cet exemple, on suppose toujours que la condition est vraie

func trigger_event(event: String):
	# Implémentez ici la logique pour déclencher des événements
	print("Event triggered: ", event)


func reset_dialogue():
	current_node = "start"

func end_dialogue():
	print("Dialogue terminé")
# Ne réinitialisez pas ici, car cela pourrait interférer avec d'autres logiques

func is_dialogue_finished() -> bool:
	# CHECK IF THE DIALOGUE FILE IS LOADED FIRST ....	
	return current_node == "end" or not dialogue_data["nodes"].has(current_node)
