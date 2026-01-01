# floating_text.gd (EL BUENO)
extends Node2D

@onready var label = $Label
var texto: String = "PERFECT!"
var color_texto: Color = Color.WHITE

func _ready():
	label.text = texto
	label.modulate = color_texto
	
	# Animación
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 50, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
