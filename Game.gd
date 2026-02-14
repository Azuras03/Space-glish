extends Control

var lives = 3
var current_question = null
var is_answering = false
var time_limit = 15.0 # Sera écrasé par GameManager

@onready var question_label = $Content/QuestionLabel
@onready var options_container = $Content/OptionsContainer
@onready var lives_container = $TopBar/LivesContainer
@onready var timer_label = $TopBar/TimerLabel
@onready var feedback_panel = $FeedbackPanel
@onready var feedback_label = $FeedbackPanel/VBoxContainer/FeedbackLabel
@onready var explanation_label = $FeedbackPanel/VBoxContainer/ExplanationLabel
@onready var next_button = $FeedbackPanel/VBoxContainer/NextButton
@onready var home_button = $FeedbackPanel/VBoxContainer/HomeButton
@onready var question_timer = $QuestionTimer

func _ready():
	# Load difficulty from GameManager (Time AND Lives)
	time_limit = GameManager.current_time_limit
	lives = GameManager.current_starting_lives
	
	# Update lives display
	update_lives_ui()
	
	# Connect buttons
	next_button.pressed.connect(_on_next_pressed)
	home_button.pressed.connect(_on_home_pressed)
	# Connect timer timeout
	question_timer.timeout.connect(_on_timer_timeout)
	
	# Hide feedback initially
	feedback_panel.visible = false
	home_button.visible = false
	
	# Load first question
	load_new_question()

func _process(delta):
	if is_answering and not question_timer.is_stopped():
		var time_left = question_timer.time_left
		var seconds = floor(time_left)
		var millis = floor((time_left - seconds) * 100)
		
		# Formatage avec les millisecondes (ex: 04:85)
		timer_label.text = "Time: %02d:%02d" % [seconds, millis]
		
		if time_left <= 5:
			timer_label.modulate = Color(1, 0.3, 0.3)
		else:
			timer_label.modulate = Color.WHITE

func update_lives_ui():
	# Clear existing hearts
	for child in lives_container.get_children():
		child.queue_free()
	
	# Add hearts based on current lives
	for i in range(lives):
		var heart = Label.new()
		heart.text = "❤️"
		heart.add_theme_font_size_override("font_size", 24)
		lives_container.add_child(heart)

func shake_lives_ui():
	# Set pivot offset to center for rotation
	lives_container.pivot_offset = lives_container.size / 2
	
	# Create a new tween for the animation
	var tween = create_tween()
	
	# Simple shake animation (rotation)
	tween.tween_property(lives_container, "rotation", 0.1, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(lives_container, "rotation", -0.1, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(lives_container, "rotation", 0.05, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(lives_container, "rotation", 0.0, 0.05).set_trans(Tween.TRANS_SINE)
	
	# Flash red
	var color_tween = create_tween()
	color_tween.tween_property(lives_container, "modulate", Color.RED, 0.1)
	color_tween.tween_property(lives_container, "modulate", Color.WHITE, 0.2)

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
	
	# Reset and start timer
	is_answering = true
	question_timer.wait_time = time_limit
	question_timer.start()
	timer_label.text = "Time: %02d:00" % [time_limit]
	timer_label.modulate = Color.WHITE

func _on_option_selected(index):
	if not is_answering: return
	is_answering = false
	question_timer.stop() # Stop timer immediately
	
	var correct_index = int(current_question["correct_index"])
	var is_correct = (index == correct_index)
	
	show_feedback(is_correct)

func _on_timer_timeout():
	if not is_answering: return
	is_answering = false
	# Timer finished naturally, treat as incorrect
	show_feedback(false, true)

func show_feedback(is_correct, time_out = false):
	feedback_panel.visible = true
	
	if is_correct:
		feedback_label.text = "Correct!"
		feedback_label.modulate = Color.GREEN
		explanation_label.text = "Well done!"
		next_button.text = "Next Question"
		home_button.visible = false
	else:
		lives -= 1
		update_lives_ui()
		shake_lives_ui()
		
		if time_out:
			feedback_label.text = "Time's Up!"
		else:
			feedback_label.text = "Incorrect!"
			
		feedback_label.modulate = Color.RED
		explanation_label.text = current_question.get("explanation", "No explanation available.")
		
		if lives <= 0:
			next_button.text = "Restart Game"
			home_button.visible = true
		else:
			next_button.text = "Next Question"
			home_button.visible = false

func _on_next_pressed():
	if lives <= 0:
		# Restart game (reload current scene)
		get_tree().reload_current_scene()
		# Lives will be reset in _ready because GameManager still holds the difficulty settings
	else:
		load_new_question()

func _on_home_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
