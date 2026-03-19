extends Control

# Partie score
var score: int = 0

# Partie timers (spawn des questions)
var waitTime: int = 10
var waitTimeMinus: int = 1
var minWaitTime: int = 2

# Partie vies
var vies = 1

@onready var nextQuestionTimer = $NextQuestionTimer
@onready var scoreElement = $TopBar/Score
@onready var gamesAppender = $GamesAppender
@onready var livesContainer = $TopBar/LivesContainer
@onready var pauseModule = $PauseModule
@onready var scoreLabel = $EndGamePanel/VBoxContainer/ScoreLabel
@onready var endGamePanel = $EndGamePanel
@onready var menuButton = $EndGamePanel/VBoxContainer/HBoxContainer/MenuButton
@onready var retryButton = $EndGamePanel/VBoxContainer/HBoxContainer/RetryButton

@export var question_scene: PackedScene

func _ready():
	# retirer la visibilité du scoreLabel
	endGamePanel.visible = false;
	# Première mise à jour des vies
	update_lives_ui()
	
	# initialisation des boutons de fin
	menuButton.pressed.connect(on_menu_pressed)
	retryButton.pressed.connect(on_retry_pressed)
	
	scoreElement.text = "Score : 0"
	nextQuestionTimer.wait_time = waitTime
	nextQuestionTimer.timeout.connect(_on_timer_timeout)
	nextQuestionTimer.start()
	spawn_question()
	pauseModule.pause_game.connect(_on_pause)

func on_menu_pressed():
	get_tree().change_scene_to_file.bind("res://Scenes/MainMenu.tscn").call_deferred()

func on_retry_pressed():
	get_tree().change_scene_to_file.bind("res://Scenes/rapid_game.tscn").call_deferred()
	
func _on_pause(paused: bool):
	nextQuestionTimer.paused = paused;

func _on_timer_timeout():
	spawn_question()
	if (waitTime > minWaitTime+1):
		waitTime -= waitTimeMinus
	nextQuestionTimer.wait_time = randf_range(minWaitTime, waitTime)
	nextQuestionTimer.start()

func update_lives_ui():
	livesContainer.text = ""
	for i in range(vies):
		livesContainer.text += "❤️"

func spawn_question():
	var screen_size = get_viewport().get_visible_rect().size
	
	# 1. On crée une instance de la scène
	var new_question = question_scene.instantiate() as GamePopUp
	var maxPosition = screen_size - new_question.size
	var randPos = Vector2(randf_range(0, maxPosition.x), randf_range(0, maxPosition.y))
	new_question.position = randPos
	# 2. On l'ajoute à la scène principale
	new_question.question_answered.connect(_on_question_answered)
	new_question.signalTimeout = pauseModule.pause_game;
	gamesAppender.add_child(new_question)
	gamesAppender.move_child(new_question, 0)
	AnimationUtils.animateBeginning(new_question)
	

# Cette fonction s'exécutera automatiquement quand le joueur cliquera sur un bouton
func _on_question_answered(is_correct: bool):
	if is_correct:
		score += 10
		scoreElement.text = str("Score : ", score)
		# Ajouter des points au score, lancer un son de victoire, etc.
	else:
		scoreElement.text = str("Score : ", score)
		vies -= 1
		if (vies <= 0):
			nextQuestionTimer.paused = true
			scoreLabel.text = scoreElement.text
			endGamePanel.visible = true
		update_lives_ui()
		shake_element(livesContainer)


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
