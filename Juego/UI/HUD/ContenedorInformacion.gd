class_name ContenedorInformacion
extends NinePatchRect

## Atributos Export
export var auto_ocultar:bool = false setget set_auto_ocultar

## Atributos Onready
onready var animaciones := $AnimationPlayer
onready var texto_contenedor := $Label
onready var auto_ocultar_timer := $AutoOcultarTimer

## Atributos
var esta_activo:bool = true setget set_esta_activo

## Setters y Getters
func set_auto_ocultar(valor:bool) -> void:
	auto_ocultar = valor

func set_esta_activo(valor:bool) -> void:
	esta_activo = valor

## Métodos
func mostrar() -> void:
	if esta_activo:
		animaciones.play("mostrar")

func ocultar() -> void:
	if not esta_activo:
		animaciones.stop()
	animaciones.play("ocultar")

func mostrar_suavizado() -> void:
	if not esta_activo:
		return
	animaciones.play("mostrar_suavizado")

func ocultar_suavizado() -> void:
	if esta_activo:
		animaciones.play("ocultar_suavizado")

func modificar_texto(text:String) -> void:
	texto_contenedor.text = text

func _on_AutoOcultarTimer_timeout() -> void:
	ocultar_suavizado()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "mostrar_suavizado" and auto_ocultar:
		auto_ocultar_timer.start()
