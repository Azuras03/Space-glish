extends Button
class_name SoundButton

func _init() -> void:
	# On se connecte ici pour être sûr que ça marche même si ajouté dynamiquement
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if SoundManager.has_method("play_click_sound"):
		SoundManager.play_click_sound()
