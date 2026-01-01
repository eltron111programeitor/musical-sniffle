extends Area2D

var text_manager = null
var is_pressed: bool = false
var tipo_flecha: String = "right"
var color_original: Color = Color.WHITE

func _ready():
	print("Right arrow ready!")
	position = Vector2(750, 600)
	$Sprite2D.rotation_degrees = -90
	$CollisionShape2D.rotation_degrees = $Sprite2D.rotation_degrees
	
	color_original = $Sprite2D.modulate
	call_deferred("buscar_text_manager")

func buscar_text_manager():
	text_manager = get_parent().get_node("TextManager")
	
	if not text_manager:
		text_manager = get_tree().get_first_node_in_group("text_manager")
	
	if text_manager:
		print("TextManager encontrado para RIGHT")
	else:
		print("ADVERTENCIA: TextManager no encontrado para RIGHT")

func _input(event):
	if event.is_action_pressed("ui_right"):
		if not is_pressed:
			is_pressed = true
			scale_down()
			verificar_notas_cercanas()
	
	if event.is_action_released("ui_right"):
		if is_pressed:
			is_pressed = false
			scale_up()
			restaurar_color()

func scale_down():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(0.7, 0.7), 0.1)

func scale_up():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.1)

func poner_flecha_morada():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.PURPLE, 0.1)
	
	if GlobalSignals.instance:
		GlobalSignals.instance.flecha_morada.emit(tipo_flecha)
	
	print("Flecha " + tipo_flecha + " morada (no había notas)")

func restaurar_color():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", color_original, 0.1)

func verificar_notas_cercanas():
	var notas = get_overlapping_areas()
	var nota_golpeada = false
	var mejor_timing = "MISS"
	var mejor_distancia = 1000.0
	var puntos_vida = 0
	
	if notas.size() == 0:
		poner_flecha_morada()
		mejor_timing = "MISS"
		puntos_vida = -15
		
		if GlobalSignals.instance:
			GlobalSignals.instance.nota_fallada.emit(puntos_vida)
		
		if text_manager:
			text_manager.mostrar_texto(mejor_timing, tipo_flecha)
		
		print("RIGHT: MISS (no había notas)")
		return
	
	for nota in notas:
		if nota.is_in_group("nota_enemiga"):
			var distancia = abs(position.y - nota.position.y)
			var timing_resultado = calcular_timing(distancia)
			
			if distancia < mejor_distancia:
				mejor_distancia = distancia
				mejor_timing = timing_resultado
			
			print("RIGHT - Distancia: " + str(int(distancia)) + " -> " + timing_resultado)
			
			if nota.tipo_nota == tipo_flecha and timing_resultado != "MISS":
				nota_golpeada = true
				
				match timing_resultado:
					"PERFECT!":
						puntos_vida = 15
					"GOOD":
						puntos_vida = 10
					"BAD":
						puntos_vida = -5
				
				nota.golpear_nota(tipo_flecha, puntos_vida)
	
	if not nota_golpeada:
		poner_flecha_morada()
		mejor_timing = "MISS"
		puntos_vida = -15
		
		if GlobalSignals.instance:
			GlobalSignals.instance.nota_fallada.emit(puntos_vida)
		
		print("RIGHT: " + mejor_timing + " (nota incorrecta o timing malo)")
	
	if text_manager:
		text_manager.mostrar_texto(mejor_timing, tipo_flecha)

func calcular_timing(distancia: float) -> String:
	if distancia < 15:
		return "PERFECT!"
	elif distancia < 30:
		return "GOOD"
	elif distancia < 50:
		return "BAD"
	else:
		return "MISS"
