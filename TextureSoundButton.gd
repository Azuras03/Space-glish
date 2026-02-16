extends TextureButton
class_name TextureSoundButton

func _init() -> void:
	# On se connecte ici pour être sûr que ça marche même si ajouté dynamiquement
	pressed.connect(_on_pressed)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_pivot()

func set_pivot() -> void:
	pivot_offset = size/2

func _on_pressed() -> void:
	if SoundManager.has_method("play_click_sound"):
		SoundManager.play_click_sound()

func _on_mouse_entered() -> void:
	create_tween().tween_property(self, "scale", Vector2(1.1,1.1), .1)

func _on_mouse_exited() -> void:
	create_tween().tween_property(self, "scale", Vector2(1,1), .1)
