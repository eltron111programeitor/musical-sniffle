extends Area2D

var text_manager = null
var is_pressed: bool = false
var tipo_flecha: String = "left"
var color_original: Color = Color.WHITE  # Para restaurar color

func _ready():
	print("Left arrow ready!")
	position = Vector2(450, 600)
	$Sprite2D.rotation_degrees = 90
	$CollisionShape2D.rotation_degrees = $Sprite2D.rotation_degrees
	
	# Guardar color original
	color_original = $Sprite2D.modulate
	
	# Buscar TextManager después de todo está listo
	call_deferred("buscar_text_manager")

func buscar_text_manager():
	text_manager = get_parent().get_node("TextManager")
	
	if not text_manager:
		# Buscar por nombre en toda la escena
		text_manager = get_tree().get_first_node_in_group("text_manager")
	
	if text_manager:
		print("TextManager encontrado para LEFT")
	else:
		print("ADVERTENCIA: TextManager no encontrado para LEFT")

func _input(event):
	if event.is_action_pressed("ui_left"):
		if not is_pressed:
			is_pressed = true
			scale_down()
			verificar_notas_cercanas()
	
	if event.is_action_released("ui_left"):
		if is_pressed:
			is_pressed = false
			scale_up()
			# Restaurar color original cuando sueltas
			restaurar_color()

func scale_down():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(0.7, 0.7), 0.1)

func scale_up():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.1)

# FUNCIÓN PARA PONER FLECHA MORADA
func poner_flecha_morada():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.PURPLE, 0.1)
	
	# Emitir señal para que otros sistemas sepan
	if GlobalSignals.instance:
		GlobalSignals.instance.flecha_morada.emit(tipo_flecha)
	
	print("Flecha " + tipo_flecha + " morada (no había notas)")

# FUNCIÓN PARA RESTAURAR COLOR
func restaurar_color():
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", color_original, 0.1)

func verificar_notas_cercanas():
	var notas = get_overlapping_areas()
	var nota_golpeada = false
	var mejor_timing = "MISS"
	var mejor_distancia = 1000.0
	var puntos_vida = 0  # Para enviar a healthbar
	
	# Si NO hay notas, poner morada y MISS
	if notas.size() == 0:
		poner_flecha_morada()
		mejor_timing = "MISS"
		puntos_vida = -15  # MISS quita 15 vida
		
		# Enviar a healthbar
		if GlobalSignals.instance:
			GlobalSignals.instance.nota_fallada.emit(puntos_vida)
		
		# Mostrar texto
		if text_manager:
			text_manager.mostrar_texto(mejor_timing, tipo_flecha)
		
		print("LEFT: MISS (no había notas)")
		return
	
	# Si HAY notas, verificar timing
	for nota in notas:
		if nota.is_in_group("nota_enemiga"):
			var distancia = abs(position.y - nota.position.y)
			var timing_resultado = calcular_timing(distancia)
			
			if distancia < mejor_distancia:
				mejor_distancia = distancia
				mejor_timing = timing_resultado
			
			print("LEFT - Distancia: " + str(int(distancia)) + " -> " + timing_resultado)
			
			# Si es la nota correcta y timing válido
			if nota.tipo_nota == tipo_flecha and timing_resultado != "MISS":
				nota_golpeada = true
				
				# Determinar puntos según timing
				match timing_resultado:
					"PERFECT!":
						puntos_vida = 15
					"GOOD":
						puntos_vida = 10
					"BAD":
						puntos_vida = -5  # ¡BAD ahora quita vida!
				
				# Golpear nota con los puntos
				nota.golpear_nota(tipo_flecha, puntos_vida)
	
	# Si no golpeó nota correcta pero había notas
	if not nota_golpeada:
		poner_flecha_morada()
		mejor_timing = "MISS"
		puntos_vida = -15
		
		# Enviar a healthbar
		if GlobalSignals.instance:
			GlobalSignals.instance.nota_fallada.emit(puntos_vida)
		
		print("LEFT: " + mejor_timing + " (nota incorrecta o timing malo)")
	
	# Mostrar texto del timing
	if text_manager:
		text_manager.mostrar_texto(mejor_timing, tipo_flecha)
	
	# Si golpeó nota, ya se enviaron puntos desde nota.golpear_nota()

func calcular_timing(distancia: float) -> String:
	if distancia < 15:
		return "PERFECT!"
	elif distancia < 30:
		return "GOOD"
	elif distancia < 50:
		return "BAD"
	else:
		return "MISS"
