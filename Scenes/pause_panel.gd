extends Node

var isPause = false

@onready var pause_panel = $PausePanel
@onready var play_button_pause = $PausePanel/VBoxContainer/HBoxContainer/PlayButton
@onready var home_button_pause = $PausePanel/VBoxContainer/HBoxContainer/HomeButton
@onready var musicPauseButton = $PausePanel/VBoxContainer/HBoxContainer/MusicPauseButton
@onready var pause_button = $PauseButton


signal pause_game(paused: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_panel.visible = false
	pause_button.pressed.connect(pause)
	# Connect buttons
	#restart_button.pressed.connect(replay)
	musicPauseButton.pressed.connect(toggleMusic)
	#home_button.pressed.connect(home)
	play_button_pause.pressed.connect(play)
	home_button_pause.pressed.connect(home)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func home():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func replay():
	get_tree().reload_current_scene()

func toggleMusic():
	#music.playing = !music.playing
	pass

func pauseGame():
	if !isPause:
		# Partie pause
		pause()
		return
	# Partie unpause
	play()

func play():
	pause_game.emit(false)
	isPause = false
	pause_panel.visible = false;
	#question_timer.paused = false;

func pause():
	pause_game.emit(true)
	isPause = true
	#question_timer.paused = true;
	pause_panel.visible = true;
