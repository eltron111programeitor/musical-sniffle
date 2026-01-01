# GlobalSignals.gd
extends Node

# Señales para comunicación global CON PARÁMETROS
signal nota_acertada(puntos: int)
signal nota_fallada(puntos: int)
signal vida_cambiada(vida_nueva: int)
signal game_over
signal flecha_morada(tipo_flecha: String)

# Singleton para acceder fácilmente
static var instance: GlobalSignals

func _ready():
	instance = self
