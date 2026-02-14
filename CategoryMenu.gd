extends Control

func _ready():
	$VBoxContainer/ConjugationBtn.pressed.connect(_on_category_selected.bind("res://Config/conjugation.json"))
	$VBoxContainer/PhrasalBtn.pressed.connect(_on_category_selected.bind("res://Config/phrasal_verbs.json"))
	$VBoxContainer/MixedBtn.pressed.connect(_on_category_selected.bind("res://Config/questions.json"))

func _on_category_selected(file_path: String):
	GameManager.load_questions(file_path)
	get_tree().change_scene_to_file("res://Scenes/DifficultyMenu.tscn")
