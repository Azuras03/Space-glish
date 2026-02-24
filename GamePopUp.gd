extends Control

var current_question = null
var is_answering = false
var time_limit = 15.0 # Sera écrasé par GameManager

@onready var question_label = $Content/QuestionLabel
@onready var options_container = $Content/OptionsContainer
@onready var lives_container = $TopBar/LivesContainer
@onready var time_bar = $TimeBar
@onready var question_timer = $QuestionTimer
@onready var window_grabber = $WindowGrabber

var is_dragging = false
var offset = Vector2.ZERO # Pour mémoriser où on a cliqué à l'intérieur du bouton

signal question_answered(is_correct: bool)

func _ready():
	# Load difficulty from GameManager (Time AND Lives)
	time_limit = GameManager.current_time_limit

	# Connect timer timeout
	question_timer.timeout.connect(_on_timer_timeout)
	window_grabber.gui_input.connect(_on_window_grabber_pressed)

	# Initialize time bar
	time_bar.max_value = time_limit
	time_bar.value = time_limit

	# Load first question
	load_new_question()

func _on_window_grabber_pressed(event):
	# Début du drag
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				offset = get_global_mouse_position() - global_position
			else:
				is_dragging = false
	# Si on drag 
	if event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() - offset

func _process(delta):
	if is_answering and not question_timer.is_stopped():
		time_bar.value = question_timer.time_left

		if question_timer.time_left <= 5:
			time_bar.modulate = Color(1, 0.3, 0.3)
		else:
			time_bar.modulate = Color.WHITE

func update_lives_ui():
	# Clear existing hearts
	for child in lives_container.get_children():
		child.queue_free()
	
func load_new_question():
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
		btn.custom_minimum_size = Vector2(100, 50)
		btn.add_theme_font_size_override("font_size", 20)
		# On connecte l'index d'origine pour que la vérification reste correcte
		btn.pressed.connect(_on_option_selected.bind(option_data["original_index"]))
		options_container.add_child(btn)
	
	# Reset and start timer
	is_answering = true
	question_timer.wait_time = time_limit
	question_timer.start()
	time_bar.max_value = time_limit
	time_bar.value = time_limit
	time_bar.modulate = Color.WHITE

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
	if is_correct:
		question_answered.emit(true)
	else:
		question_answered.emit(false)
