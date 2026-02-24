extends Control

var score: int = 0
@onready var scoreElement = $Label
@onready var gamesAppender = $GamesAppender
@export var question_scene: PackedScene
func _ready():
	scoreElement.text = "SALU"
	# Faisons spawn une question dès le début pour tester
	spawn_question()

func spawn_question():
	if question_scene:
		# 1. On crée une instance de la scène
		var new_question = question_scene.instantiate()
		# 2. On l'ajoute à la scène principale
		gamesAppender.add_child(new_question)
		
		# 3. LE FAMEUX BRIDGE : on connecte le signal de la question à une fonction d'ici
		new_question.question_answered.connect(_on_question_answered)

# Cette fonction s'exécutera automatiquement quand le joueur cliquera sur un bouton
func _on_question_answered(is_correct: bool):
	if is_correct:
		score += 10
		scoreElement.text = str("Score : ", score)
		print("Super ! Bonne réponse.")
		# Ajouter des points au score, lancer un son de victoire, etc.
	else:
		scoreElement.text = str("Score : ", score)
		print("Dommage, mauvaise réponse.")
		# Retirer une vie, afficher la correction, etc.
