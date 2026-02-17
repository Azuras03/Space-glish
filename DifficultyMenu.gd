extends Control

func _ready():
	# Connecter les boutons manuellement ou via l'éditeur
	# Ici je suppose que les nœuds s'appellent EasyBtn, NormalBtn, etc.
	$VBoxContainer/EasyBtn.pressed.connect(_on_difficulty_selected.bind("easy"))
	$VBoxContainer/NormalBtn.pressed.connect(_on_difficulty_selected.bind("normal"))
	$VBoxContainer/HardBtn.pressed.connect(_on_difficulty_selected.bind("hard"))
	$VBoxContainer/HardcoreBtn.pressed.connect(_on_difficulty_selected.bind("hardcore"))
	$VBoxContainer/EndlessBtn.pressed.connect(_endless_mode)

func _on_difficulty_selected(difficulty: String):
	GameManager.set_difficulty(difficulty)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _endless_mode():
	GameManager.set_difficulty("endless")
	get_tree().change_scene_to_file("res://Scenes/EndlessGame.tscn")
