class_name EnemigoOrbital
extends EnemigoBase


## Atributos Export
export var rango_max_ataque:float = 1400.0

## Atributos
var base_duenia:Node2D

## Constructor
func crear(pos:Vector2, duenia:Node2D) -> void:
	global_position = pos
	base_duenia = duenia

## Métodos
func _ready() -> void:
	Eventos.connect("base_destruida", self, "_on_base_destruida")

## Métodos Custom
func rotar_hacia_player() -> void:
	.rotar_hacia_player()
	if dir_player.length() > rango_max_ataque:
		canion.set_esta_disparando(false)
	else:
		canion.set_esta_disparando(true)

# Señales Internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)

## Señales Externas
func _on_base_destruida(base:Node2D, _pos) -> void:
	if base == base_duenia:
		destruir()
