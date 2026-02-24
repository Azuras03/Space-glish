extends Control

# Partie score
var score: int = 0

# Partie timers (spawn des questions)
var waitTime: int = 10
var waitTimeMinus: int = .5
var minWaitTime: int = 2

# Partie vies
var vies = 10

@onready var nextQuestionTimer = $NextQuestionTimer
@onready var scoreElement = $TopBar/Label
@onready var gamesAppender = $GamesAppender
@onready var livesContainer = $TopBar/LivesContainer

@export var question_scene: PackedScene

func _ready():
	# Première mise à jour des vies
	update_lives_ui()
	
	scoreElement.text = "Score : 0"
	nextQuestionTimer.wait_time = waitTime
	nextQuestionTimer.timeout.connect(_on_timer_timeout)
	nextQuestionTimer.start()
	spawn_question()

func _on_timer_timeout():
	print("Salu")
	spawn_question()
	if (waitTime > minWaitTime):
		nextQuestionTimer.wait_time -= waitTimeMinus
	nextQuestionTimer.start()

func update_lives_ui():
	livesContainer.text = ""
	for i in range(vies):
		livesContainer.text += "❤️"

func spawn_question():
	var screen_size = get_viewport().get_visible_rect().size
	
	# 1. On crée une instance de la scène
	var new_question = question_scene.instantiate()
	var maxPosition = screen_size - new_question.size
	var randPos = Vector2(randf_range(0, maxPosition.x), randf_range(0, maxPosition.y))
	new_question.position = randPos
	# 2. On l'ajoute à la scène principale
	gamesAppender.add_child(new_question)
	gamesAppender.move_child(new_question, 0)
	AnimationUtils.animateBeginning(new_question)
	
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
		vies -= 1
		update_lives_ui()
		shake_element(livesContainer)
		# TODO Gérér la fin (quand on a plus de vie)
		# Donc une page avec le score et le boutons qui vont bien hehe


func shake_element(element):
	# Set pivot offset to center for rotation
	element.pivot_offset = element.size / 2
	
	# Create a new tween for the animation
	var tween = create_tween()
	
	# Simple shake animation (rotation)
	tween.tween_property(element, "rotation", 0.1, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(element, "rotation", -0.1, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(element, "rotation", 0.05, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(element, "rotation", 0.0, 0.05).set_trans(Tween.TRANS_SINE)
	
	# Flash red
	var color_tween = create_tween()
	color_tween.tween_property(element, "modulate", Color.RED, 0.1)
	color_tween.tween_property(element, "modulate", Color.WHITE, 0.2)
