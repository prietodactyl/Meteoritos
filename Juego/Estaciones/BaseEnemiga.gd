class_name BaseEnemiga
extends Node2D

## Atributos Export
export var hitpoints:float = 30.0
export var orbital:PackedScene = null

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
	Eventos.emit_signal("base_destruida", self, posicion_partes)
	queue_free()

func spawnear_orbital() -> void:
	var pos_spawn:Vector2 = deteccion_cuadrante()
	
	var new_orbital:EnemigoOrbital = orbital.instance()
	new_orbital.crear(
		global_position + pos_spawn,
		self
	)
	Eventos.emit_signal("spawn_orbital", new_orbital)

func deteccion_cuadrante() -> Vector2:
	var player_objetivo:Player = DatosJuego.get_player_actual()
	
	if not player_objetivo:
		return Vector2.ZERO
	
	var dir_player:Vector2 = player_objetivo.global_position - global_position
	var angulo_player:float = rad2deg(dir_player.angle())
	
	if abs(angulo_player) <= 45.0:
		return $PuntoSpawn/Este.position
	elif abs(angulo_player) > 135.0 and abs(angulo_player) <= 180.0:
		return $PuntoSpawn/Oeste.position
	elif abs(angulo_player) > 45.0 and abs(angulo_player) <= 135.0:
		if sign(angulo_player) > 0:
			return $PuntoSpawn/Sur.position
		else:
			return $PuntoSpawn/Norte.position
	
	return $PuntoSpawn/Norte.position

## Señales Internas
func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()


func _on_VisibilityNotifier2D_screen_entered() -> void:
	spawnear_orbital()	
	$VisibilityNotifier2D.queue_free()
