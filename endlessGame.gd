extends Control

var lives = 3
var current_question = null
var is_answering = false
var isPause = false
var combo = 1
var time_limit = 15.0 # Sera écrasé par GameManager
var score=0

@onready var question_label = $Content/QuestionLabel
@onready var options_container = $Content/OptionsContainer
@onready var score_label = $TopBar/ScoreLabel
@onready var timer_label = $TopBar/TimerLabel
@onready var feedback_panel = $FeedbackPanel
@onready var feedback_label = $FeedbackPanel/VBoxContainer/FeedbackLabel
@onready var explanation_label = $FeedbackPanel/VBoxContainer/ExplanationLabel
@onready var restart_button = $FeedbackPanel/VBoxContainer/RestartButton
@onready var home_button = $FeedbackPanel/VBoxContainer/HomeButton
@onready var question_timer = $QuestionTimer
@onready var combo_bar = $ComboBar
@onready var pause_button = $TopBar/PauseButton
@onready var pause_panel = $PausePanel
@onready var play_button_pause = $PausePanel/VBoxContainer/HBoxContainer/PlayButton
@onready var home_button_pause = $PausePanel/VBoxContainer/HBoxContainer/HomeButton
@onready var musicPauseButton = $PausePanel/VBoxContainer/HBoxContainer/MusicPauseButton
# Musique
@onready var music = $MusicPlayer

func _ready():
	music.play()
	pause_panel.visible = false
	pause_button.pressed.connect(pause)
	# Load difficulty from GameManager (Time AND Lives)
	time_limit = GameManager.current_time_limit
	print(time_limit)
	lives = GameManager.current_starting_lives
	
	# Connect buttons
	restart_button.pressed.connect(replay)
	musicPauseButton.pressed.connect(toggleMusic)
	home_button.pressed.connect(home)
	play_button_pause.pressed.connect(play)
	home_button_pause.pressed.connect(home)
	# Connect timer timeout
	question_timer.timeout.connect(_on_timer_timeout)
	
	question_timer.wait_time = time_limit
	question_timer.start()
	# Hide feedback initially
	feedback_panel.visible = false
	home_button.visible = false
	
	# Load first question
	load_new_question()

func home():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func replay():
	get_tree().reload_current_scene()

func toggleMusic():
	music.playing = !music.playing

func pauseGame():
	if !isPause:
		# Partie pause
		pause()
		return
	# Partie unpause
	play()

func play():
	isPause = false
	pause_panel.visible = false;
	question_timer.paused = false;

func pause():
	isPause = true
	question_timer.paused = true;
	pause_panel.visible = true;

func _process(delta):
	if not question_timer.is_stopped():
		var time_left = question_timer.time_left
		var seconds = floor(time_left)
		var millis = floor((time_left - seconds) * 100)
		
		# Formatage avec les millisecondes (ex: 04:85)
		timer_label.text = "Time: %02d:%02d" % [seconds, millis]
		
		if time_left <= 5:
			timer_label.modulate = Color(1, 0.3, 0.3)
		else:
			timer_label.modulate = Color.WHITE

func load_new_question():
	feedback_panel.visible = false
	home_button.visible = false
	
	current_question = GameManager.get_random_question()
	if current_question == null:
		question_label.text = "Error: No questions found in JSON!"
		return

	question_label.text = current_question["question"]
	
	# Clear old buttons
	for child in options_container.get_children():
		child.queue_free()
	
	# Create new buttons with randomized order
	var options = current_question["options"]
	var correct_index = int(current_question["correct_index"])
	
	# On crée une liste d'objets pour garder trace de l'index d'origine
	var randomized_options = []
	for i in range(options.size()):
		randomized_options.append({
			"text": options[i],
			"original_index": i
		})
	
	# On mélange la liste
	randomized_options.shuffle()
	
	for option_data in randomized_options:
		var btn = SoundButton.new()
		btn.text = option_data["text"]
		btn.custom_minimum_size = Vector2(200, 50)
		btn.add_theme_font_size_override("font_size", 20)
		# On connecte l'index d'origine pour que la vérification reste correcte
		btn.pressed.connect(_on_option_selected.bind(option_data["original_index"]))
		options_container.add_child(btn)

func scale_element(scale, element, color):
	# Set pivot offset to center for rotation
	element.pivot_offset = element.size / 2
	
	# Create a new tween for the animation
	var tween = create_tween()
	
	# Simple shake animation (rotation)
	tween.tween_property(element, "scale", Vector2(scale, scale), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(element, "scale", Vector2(1,1), 0.3).set_ease(Tween.EASE_IN_OUT)
	var color_tween = create_tween()
	color_tween.tween_property(element, "modulate", color, 0.1)
	color_tween.tween_property(element, "modulate", Color.WHITE, 0.3)

func _on_option_selected(index):	
	var correct_index = int(current_question["correct_index"])
	var is_correct = (index == correct_index)
	
	show_feedback(is_correct)

func _on_timer_timeout():
	endGame()

func endGame():
	feedback_panel.visible = true
	feedback_label.text = "End !"
	restart_button.text = "Restart Game"
	home_button.visible = true

func show_feedback(is_correct, time_out = false):
	if(is_correct):
		score += 100*combo
		score_label.text = str("Score :", score)
		scale_element(min(1.1+(combo/10),2), score_label, Color.GREEN)
		combo+=1
		combo_bar.text = str("x",combo)
	else:
		score_label.text = str("Score :", score)
		combo=1
		combo_bar.text = str("x",combo)
		scale_element(.8, combo_bar, Color.RED)
	load_new_question()
