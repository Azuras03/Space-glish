extends Control

signal file_selected_async(path: String)

func _ready():
	$BackButton.pressed.connect(_on_quit_button)
	$VBoxContainer/ConjugationBtn.pressed.connect(_on_category_selected.bind("res://Config/conjugation.json"))
	$VBoxContainer/PhrasalBtn.pressed.connect(_on_category_selected.bind("res://Config/phrasal_verbs.json"))
	$VBoxContainer/MixedBtn.pressed.connect(_on_category_selected.bind("res://Config/questions.json"))
	$VBoxContainer/ImportBtn.pressed.connect(_import_button_action)

func _on_quit_button():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_category_selected(file_path: String):
	GameManager.load_questions(file_path)
	get_tree().change_scene_to_file("res://Scenes/DifficultyMenu.tscn")

func _import_button_action():
	var file_path: String = await _import_file()
	if (file_path == ""): # Aucun fichier n'a été sélectionné
		return
	GameManager.load_questions(file_path)
	var tree = Engine.get_main_loop() as SceneTree

	if tree:
	# 2. On change la scène de manière différée (très important après un callback natif)
		tree.call_deferred("change_scene_to_file", "res://Scenes/DifficultyMenu.tscn")
	else:
		print("Erreur critique : Impossible de trouver le SceneTree.")

func _import_file():
	# 1. On définit les types de fichiers qu'on accepte (ici txt et json)
	var filtres = PackedStringArray(["*.txt, *.json ; Fichiers de texte et données"])
	
	DisplayServer.file_dialog_show(
		"Importer des questions", 
		"", 
		"", 
		false, 
		DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, 
		filtres, 
		_on_fichier_selectionne
	)
	
	var resultat_chemin: String = await file_selected_async
	return resultat_chemin
	
func _on_fichier_selectionne(status: bool, chemins_selectionnes: PackedStringArray, index_filtre: int):
	# Si status est "true", c'est que l'utilisateur a cliqué sur "Ouvrir" (et non "Annuler")
	if status and chemins_selectionnes.size() > 0:
		var chemin_du_fichier = chemins_selectionnes[0]
		file_selected_async.emit(chemin_du_fichier)
	else:
		file_selected_async.emit("")
