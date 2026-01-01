extends Area2D

@export var velocidad: float = 200.0
@export var tipo_nota: String = "left"
# NUEVA: Variable para rotación
@export var rotacion_flecha: float = 0.0

var activa: bool = true
var screen_bottom: float = 600

func _ready():
	position = Vector2(obtener_posicion_x(), -50)
	add_to_group("nota_enemiga")
	
	# APLICAR ROTACIÓN AL SPRITE
	if has_node("Sprite2D"):
		$Sprite2D.rotation_degrees = rotacion_flecha
		print("Nota " + tipo_nota + " creada con rotación: " + str(rotacion_flecha) + "°")
	else:
		print("Nota " + tipo_nota + " creada (sin Sprite2D para rotar)")

func obtener_posicion_x() -> float:
	match tipo_nota:
		"left": return 450
		"down": return 650
		"up": return 550
		"right": return 750
	return 250

func _process(delta):
	position.y += velocidad * delta
	
	# Ajusta esto para que coincida con Y de los receptores (600)
	if position.y > 650 and activa:  # Deja un margen de 50px
		# Cuando la nota se pierde (sale de pantalla) es un MISS
		print("Nota " + tipo_nota + " perdida - MISS automático")
		
		# Enviar -15 vida por MISS
		if GlobalSignals.instance:
			GlobalSignals.instance.nota_fallada.emit(-15)
		
		queue_free()

# MODIFICAR golpear_nota() para aceptar puntos
func golpear_nota(tipo_receptor: String = "", puntos: int = 10):  # <- AGREGAR PUNTOS
	if activa:
		if tipo_receptor == tipo_nota:
			activa = false
			print("¡Nota " + tipo_nota + " GOLPEADA! Puntos: " + str(puntos))
			
			# Usar señal global CON PUNTOS
			if GlobalSignals.instance:
				if puntos > 0:
					GlobalSignals.instance.nota_acertada.emit(puntos)
				else:
					GlobalSignals.instance.nota_fallada.emit(puntos)
			else:
				print("ADVERTENCIA: GlobalSignals no disponible")
			
			queue_free()
			return true
	return false

func destruir_nota(razon: String):
	if activa:
		activa = false
		print("Nota " + tipo_nota + " " + razon)
		
		# Usar señal global
		if GlobalSignals.instance:
			GlobalSignals.instance.nota_fallada.emit(-15)  # MISS = -15
		else:
			print("ADVERTENCIA: GlobalSignals no disponible")
		
		queue_free()
