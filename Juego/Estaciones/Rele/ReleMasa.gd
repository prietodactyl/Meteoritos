class_name ReleDeMasa
extends Node2D

## Atributos Onready
onready var animaciones:AnimationPlayer = $Animaciones
onready var colision_detector_player:CollisionShape2D = $DetectorPlayer/CollisionShape2D
onready var tween:Tween = $Tween

## Métodos
func _ready() -> void:
	Eventos.emit_signal("minimap_objeto_creado")

## Métodos Custom
func atraer_player(body: Node) -> void:
	tween.interpolate_property(
		body,
		"global_position",
		body.global_position,
		global_position,
		3.0,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	
	tween.start()

## Señales Internas
func _on_Animaciones_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		animaciones.play("activada")

func _on_DetectorPlayer_body_entered(body: Node) -> void:
	if body is Player:
		colision_detector_player.set_deferred("disabled", true)
		animaciones.play("super_activada")
		body.desactivar_controles()
		atraer_player(body)

func _on_Tween_tween_all_completed() -> void:
	Eventos.emit_signal("nivel_completado")
