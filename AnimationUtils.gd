extends Node

func animateBeginning(element):
	var tween = create_tween()
	tween.tween_property(element, "scale", Vector2(1,0),0)
	tween.tween_property(element, "scale", Vector2(1,1),0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func animateEnding(element:Node, right:bool):
	var color:Color = Color.RED
	if right:
		color = Color.GREEN
	var tween = create_tween()
	tween.tween_property(element, "scale", Vector2(1,0),0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var color_tween = create_tween()
	color_tween.tween_property(element, "modulate", color, 0.1)
	color_tween.tween_property(element, "modulate", Color.WHITE, 0.2)
	await tween.finished
	await color_tween.finished
	element.queue_free()
