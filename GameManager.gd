extends Node

var questions: Array = []
var alreadyAnsweredQuestions: Array = []
var difficulty_settings: Dictionary = {}
var lives_settings: Dictionary = {}
var current_time_limit: float = 15.0 # Valeur par défaut
var current_starting_lives: int = 3 # Valeur par défaut
var current_category_path: String = "res://Config/questions.json" # Par défaut
var truc: String = "NO"

func _ready():
	load_config()
	# On ne charge pas les questions ici, on le fera quand la catégorie sera choisie

func trucc():
	truc = "SALU"

func load_questions(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_ARRAY:
			questions = data
			current_category_path = file_path # Save for restart logic
			print("Questions loaded from ", file_path, ": ", questions.size())
		else:
			printerr("Unexpected JSON format in ", file_path)
	else:
		printerr("JSON Parse Error: ", json.get_error_message())

func load_config():
	var file_path = "res://Config/config.json"
	if not FileAccess.file_exists(file_path):
		printerr("Config file not found! Using defaults.")
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	
	if error == OK:
		var data = json.data
		if data.has("difficulties"):
			difficulty_settings = data["difficulties"]
			print("Difficulties loaded: ", difficulty_settings)
		if data.has("lives"):
			lives_settings = data["lives"]
			print("Lives loaded: ", lives_settings)
		else:
			printerr("Config JSON missing 'lives' key")
	else:
		printerr("JSON Parse Error (config): ", json.get_error_message())

func get_random_question():
	if alreadyAnsweredQuestions.size() == questions.size():
		alreadyAnsweredQuestions = []
	var pickedIndex = randi()%questions.size()
	while (alreadyAnsweredQuestions.has(pickedIndex)):
		pickedIndex = randi()%questions.size()
	alreadyAnsweredQuestions.append(pickedIndex)
	return questions[pickedIndex]

func set_difficulty(difficulty_name: String):
	# Set Time Limit
	if difficulty_settings.has(difficulty_name):
		current_time_limit = difficulty_settings[difficulty_name]
	else:
		current_time_limit = 15.0 # Fallback
	
	# Set Starting Lives
	if lives_settings.has(difficulty_name):
		current_starting_lives = int(lives_settings[difficulty_name])
	else:
		current_starting_lives = 3 # Fallback
