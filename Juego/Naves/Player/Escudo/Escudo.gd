class_name Escudo
extends Area2D

var esta_activo := false setget ,get_esta_activo

export var energia := 8.0
export var radio_desgaste := -1.6

onready var colisionador := $CollisionShape2D
onready var animacion := $AnimationPlayer

func get_esta_activo() -> bool:
	return esta_activo

func _ready() -> void:
	set_process(false)
	controlar_colisionador(true)

func _process(delta: float) -> void:
	energia += radio_desgaste * delta
	if energia <= 0.0:
		desactivar()

func activar() -> void:
	if energia <= 0.0:
		return
		
	esta_activo = true
	controlar_colisionador(false)
	animacion.play("activando")

func controlar_colisionador(esta_desactivado:bool) -> void:
	colisionador.set_deferred("disabled", esta_desactivado)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "activando":
		animacion.play("activo")
		set_process(true)
	if anim_name == "desactivando":
		animacion.play("default")

func desactivar() -> void:
	set_process(false)
	esta_activo = false
	controlar_colisionador(true)
	animacion.play("desactivando")

func _on_body_entered(body: Node) -> void:
	body.queue_free()
