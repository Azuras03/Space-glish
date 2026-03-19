extends Control

func _ready():
	# Connecter les boutons manuellement ou via l'éditeur
	# Ici je suppose que les nœuds s'appellent EasyBtn, NormalBtn, etc.
	$LearnContainer/EasyBtn.pressed.connect(_on_difficulty_selected.bind("easy"))
	$LearnContainer/HardBtn.pressed.connect(_on_difficulty_selected.bind("hard"))
	$LearnContainer/HardcoreBtn.pressed.connect(_on_difficulty_selected.bind("hardcore"))
	$SpecialContainer/EndlessBtn.pressed.connect(_endless_mode)
	$SpecialContainer/RapidBtn.pressed.connect(_rapid_game)

func _on_difficulty_selected(difficulty: String):
	GameManager.set_difficulty(difficulty)
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _endless_mode():
	GameManager.set_difficulty("endless")
	get_tree().change_scene_to_file("res://Scenes/EndlessGame.tscn")
	
func _rapid_game():
	GameManager.set_difficulty("rapid")
	get_tree().change_scene_to_file("res://Scenes/rapid_game.tscn")
