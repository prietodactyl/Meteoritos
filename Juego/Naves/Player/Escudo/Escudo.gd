class_name Escudo
extends Area2D

## Atributos
var esta_activo := false setget ,get_esta_activo
var energia_original:float

## Atributos Export
export var energia := 8.0
export var radio_desgaste := -1.6

## Atributos Onready
onready var colisionador := $CollisionShape2D
onready var animacion := $AnimationPlayer

## Setters y Getters
func get_esta_activo() -> bool:
	return esta_activo

## Métodos
func _ready() -> void:
	set_process(false)
	controlar_colisionador(true)
	energia_original = energia

func _process(delta: float) -> void:
	controlar_energia(radio_desgaste * delta)

## Métodos Custom
func activar() -> void:
	if energia <= 0.0:
		return
		
	esta_activo = true
	controlar_colisionador(false)
	animacion.play("activando")

func controlar_colisionador(esta_desactivado:bool) -> void:
	colisionador.set_deferred("disabled", esta_desactivado)

func desactivar() -> void:
	set_process(false)
	esta_activo = false
	controlar_colisionador(true)
	animacion.play("desactivando")

func controlar_energia(consumo:float) -> void:
	energia += consumo
	
	if energia > energia_original:
		energia = energia_original
	elif energia <= 0.0:
		Eventos.emit_signal("ocultar_energia_escudo")
		desactivar()
		return
	
	Eventos.emit_signal("cambio_energia_escudo", energia_original, energia)

## Señales Internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "activando":
		animacion.play("activo")
		set_process(true)
	if anim_name == "desactivando":
		animacion.play("default")

func _on_body_entered(body: Node) -> void:
	body.queue_free()
