extends Control

func _ready():
	$PlayButton.pressed.connect(_on_play_pressed)
	$QuitButton.pressed.connect(_quit_game)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/CategoryMenu.tscn")

func _quit_game():
	get_tree().quit()
