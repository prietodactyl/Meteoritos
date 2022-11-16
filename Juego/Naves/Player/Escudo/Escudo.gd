class_name Escudo
extends Area2D

onready var colisionador := $CollisionShape2D
onready var animacion := $AnimationPlayer

func _ready() -> void:
	controlar_colisionador(true)

func activar() -> void:
	controlar_colisionador(false)
	animacion.play("activando")

func controlar_colisionador(esta_desactivado:bool) -> void:
	colisionador.set_deferred("disabled", esta_desactivado)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "activando":
		animacion.play("activo")
