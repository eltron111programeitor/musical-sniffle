# TextManager.gd
extends Node2D

# Colores para cada timing
var timing_colors = {
	"PERFECT!": Color.LIME_GREEN,
	"GOOD": Color.DODGER_BLUE,
	"BAD": Color.ORANGE,
	"MISS": Color.WEB_PURPLE
}

# Posiciones X para cada flecha
var arrow_positions = {
	"left": 450,
	"down": 650,
	"up": 550,
	"right": 750
}

@export var floating_text_scene: PackedScene

func _ready():
	# Cargar escena si no se asignó
	if floating_text_scene == null:
		floating_text_scene = preload("res://scenes/FloatingText.tscn")
	
	print("=== TEXTMANAGER INICIADO ===")
	
	# Hacerse fácil de encontrar
	add_to_group("text_manager")
	
	print("✓ Registrado en grupo 'text_manager'")

# Función para mostrar texto
func mostrar_texto(texto: String, tipo_flecha: String):
	var color = timing_colors.get(texto, Color.WHITE)
	var pos_x = arrow_positions.get(tipo_flecha, 400)
	
	if floating_text_scene:
		var texto_flotante = floating_text_scene.instantiate()
		texto_flotante.position = Vector2(pos_x, 550)
		texto_flotante.texto = texto
		texto_flotante.color_texto = color
		add_child(texto_flotante)
		print("Texto mostrado: " + texto + " en " + tipo_flecha)
	else:
		print("ERROR: No hay floating_text_scene asignada")
