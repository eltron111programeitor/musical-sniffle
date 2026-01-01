# main.gd (versión final)
extends Node2D

@onready var health_bar = $HealthBar
@onready var generador_notas = $GeneradorNotas
@onready var touch_buttons = [$TouchLeft,$TouchRight,$TouchUp,$TouchDown]

# Variable para forzar controles táctiles (debug)
var forzar_touch: bool = false

func _ready():
	print("=== 🎵 FNF GAME STARTED ===")
	
	# Verificar que todo esté conectado
	verificar_nodos()
	
	# Detectar y configurar plataforma
	detectar_plataforma()
	
	# Conectar input para debug
	setup_debug_controls()

func verificar_nodos():
	print("\n=== VERIFICANDO NODOS ===")
	
	# HealthBar
	if health_bar:
		print("✅ HealthBar encontrada")
	else:
		print("❌ HealthBar NO encontrada")
	
	# Generador de notas
	if generador_notas:
		print("✅ GeneradorNotas encontrado")
	else:
		print("❌ GeneradorNotas NO encontrado")
	
	# TouchButtons
	if todos_los_botones_presentes() == true:
		print("✅ TouchButtons encontrados")
	else:
		print("❌ TouchButtons NO encontrados")

func detectar_plataforma():
	# Detectar si es móvil realmente
	var es_movil_real = OS.get_name() == "Android" or OS.get_name() == "iOS"
	
	# Si forzamos touch, mostrar siempre
	var mostrar_controles = es_movil_real or forzar_touch
	
	print("\n=== CONFIGURACIÓN PLATAFORMA ===")
	print("Sistema: " + OS.get_name())
	print("Es móvil real: " + str(es_movil_real))
	print("Forzar touch: " + str(forzar_touch))
	print("Mostrar controles: " + str(mostrar_controles))
	
	#if touch_buttons:
	#	touch_buttons.visible = mostrar_controles
		
	#	if mostrar_controles:
	#		print("📱 Controles táctiles ACTIVADOS")
	#		if forzar_touch and not es_movil_real:
	#			print("   (Forzado para pruebas en PC)")
	#	else:
		#	print("⌨️  Controles de teclado ACTIVADOS")

func setup_debug_controls():
	# Configurar tecla para alternar controles táctiles (F1)
	print("\n=== CONTROLES DEBUG ===")
	print("Presiona F1 para mostrar/ocultar controles táctiles")
	print("Presiona F2 para mostrar debug de botones")

func _input(event):
	# Alternar controles táctiles con F1
	if event.is_action_pressed("ui_f1"):
		forzar_touch = not forzar_touch
		detectar_plataforma()
		print("\n🔄 Alternando controles táctiles: " + str(forzar_touch))
		
		# MOSTRAR INFO DE CONEXIONES
		mostrar_info_conexiones()
	
	# Mostrar debug de botones con F2
	if event.is_action_pressed("ui_f2"):
		mostrar_info_conexiones()

func mostrar_info_conexiones():
	print("\n=== INFO CONEXIONES BOTONES ===")
	for boton in touch_buttons:
		if boton and is_instance_valid(boton):
			print("Botón: " + boton.name)
			print("  Posición: " + str(boton.position))
			print("  Visible: " + str(boton.visible))
			print("  Deshabilitado: " + str(boton.disabled))
			
			# Verificar a qué receptor está conectado
			var receptor = boton.get_parent().get_node(boton.name.replace("Touch", "Receptor"))
			if receptor:
				print("  Receptor conectado: " + receptor.name)
			else:
				print("  ⚠️  NO hay receptor conectado")
				
func todos_los_botones_presentes() -> bool:
	# Revisa cada botón en la lista
	for boton in touch_buttons:
		# Si UN botón falta o no es válido, retorna false
		if not boton or not is_instance_valid(boton):
			return false
	# Solo llega aquí si TODOS los botones están OK
	return true
