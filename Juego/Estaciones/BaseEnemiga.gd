class_name BaseEnemiga
extends Node2D

## Atributos Export
export var hitpoints:float = 30.0

## Atributos Onready
onready var animaciones:AnimationPlayer = $AnimationPlayer
onready var impacto_sfx:AudioStreamPlayer2D = $ImpactoSFX

## Atributos
var esta_destruido:bool = false

## Métodos
func _ready() -> void:
	animaciones.play(elegir_animacion_aleatoria())
	
## Métodos Custom
func elegir_animacion_aleatoria() -> String:
	randomize()
	var num_anim:int = animaciones.get_animation_list().size() - 1
	var indice_anim_aleatoria:int = randi() % num_anim + 1
	var lista_animacion:Array = animaciones.get_animation_list()

	return lista_animacion[indice_anim_aleatoria]

func recibir_danio(danio:float) -> void:
	hitpoints -= danio
	
	if hitpoints <= 0 and not esta_destruido:
		esta_destruido = true
		destruir()
	
	impacto_sfx.play()

func destruir() -> void:
	var posicion_partes:Array = [
		$AreaColision/Sprite/EstacionSprite1.global_position,
		$AreaColision/Sprite/EstacionSprite2.global_position,
		$AreaColision/Sprite/EstacionSprite3.global_position,
		$AreaColision/Sprite/EstacionSprite4.global_position
	]
	Eventos.emit_signal("base_destruida", posicion_partes)
	queue_free()

func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()
