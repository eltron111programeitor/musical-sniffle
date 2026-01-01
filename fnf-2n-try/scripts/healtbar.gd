# healthbar.gd
extends ProgressBar

# Configuración
@export var vida_inicial: int = 50
@export var vida_maxima: int = 100
@export var vida_minima: int = 0

var vida_actual: int
var juego_activo: bool = true

func _ready():
	# Configurar valores iniciales
	vida_actual = vida_inicial
	value = vida_actual
	max_value = vida_maxima
	min_value = vida_minima
	
	print("healthbar lista. Vida: " + str(vida_actual))
	
	# Conectar señales globales
	if GlobalSignals.instance:
		GlobalSignals.instance.nota_acertada.connect(nota_acertada)
		GlobalSignals.instance.nota_fallada.connect(nota_fallada)
	else:
		print("ADVERTENCIA: GlobalSignals no encontrado")

# Función para cambiar vida
func cambiar_vida(cantidad: int):
	if not juego_activo:
		return
	
	vida_actual += cantidad
	vida_actual = clamp(vida_actual, vida_minima, vida_maxima)
	
	# Actualizar barra
	value = vida_actual
	
	print("Vida: " + str(vida_actual) + " (" + ("+" if cantidad > 0 else "") + str(cantidad) + ")")
	
	# Verificar si perdió
	if vida_actual <= vida_minima:
		perder_juego()
	
	# Verificar si ganó (opcional)
	if vida_actual >= vida_maxima:
		print("¡Vida al máximo!")

# Cuando aciertas una nota CON PUNTOS DIFERENTES
func nota_acertada(puntos: int):
	cambiar_vida(puntos)
	print("¡Nota acertada! " + ("+" if puntos > 0 else "") + str(puntos) + " vida")

# Cuando fallas o pierdes una nota CON PUNTOS DIFERENTES
func nota_fallada(puntos: int):
	cambiar_vida(puntos)
	print("Nota fallada " + ("+" if puntos > 0 else "") + str(puntos) + " vida")

func perder_juego():
	juego_activo = false
	print("¡GAME OVER! - Vida en 0")
	# Aquí puedes: emitir señal, mostrar pantalla game over, etc.
