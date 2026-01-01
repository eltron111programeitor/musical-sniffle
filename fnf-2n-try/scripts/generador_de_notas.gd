extends Node2D

# Prefab de la nota enemiga
@export var nota_scene: PackedScene

# Patrón de notas (simple por ahora)
var patron_simple = [
	{"tiempo": 1.0, "tipo": "left"},
	{"tiempo": 1.5, "tipo": "down"},
	{"tiempo": 2.0, "tipo": "up"},
	{"tiempo": 2.5, "tipo": "right"},
	{"tiempo": 3.0, "tipo": "left"},
	{"tiempo": 3.5, "tipo": "right"},
]

var tiempo_transcurrido: float = 0.0
var indice_patron: int = 0
var juego_activo: bool = true

# Diccionario para rotaciones según tipo de flecha
var rotaciones_flechas = {
	"left": 0,     # ← Girar 90° (apunta a la izquierda)
	"down": -90,      # ↓ Sin rotación (apunta abajo)
	"up": 90,      # ↑ Girar 180° (apunta arriba)
	"right": -180    # → Girar -90° (apunta derecha)
}

func _ready():
	print("Generador de notas iniciado")
	
	# Cargar escena si no se asignó en el inspector
	if nota_scene == null:
		nota_scene = preload("res://scenes/nota_enemiga.tscn")

func _process(delta):
	if not juego_activo:
		return
	
	tiempo_transcurrido += delta
	
	# Verificar si es tiempo de crear la siguiente nota
	if indice_patron < patron_simple.size():
		var nota_actual = patron_simple[indice_patron]
		
		if tiempo_transcurrido >= nota_actual["tiempo"]:
			crear_nota(nota_actual["tipo"])
			indice_patron += 1

func crear_nota(tipo: String):
	var nueva_nota = nota_scene.instantiate()
	nueva_nota.tipo_nota = tipo
	
	# Configurar la rotación de la flecha según su tipo
	if tipo in rotaciones_flechas:
		# IMPORTANTE: Asumimos que la nota tiene un Sprite2D llamado "Sprite2D"
		# Esta rotación se aplicará cuando la nota se instancie
		# Pasamos la rotación como parámetro
		nueva_nota.rotacion_flecha = rotaciones_flechas[tipo]
	
	# Opcional: ajustar velocidad según dificultad
	# nueva_nota.velocidad = 250.0
	
	add_child(nueva_nota)
	print("Nota creada: " + tipo + " en tiempo: " + str(tiempo_transcurrido))
