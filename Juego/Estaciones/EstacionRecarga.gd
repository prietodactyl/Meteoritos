class_name EstacionRecarga
extends Node2D

signal sin_energia()

## Atributos Export
export var energia:float = 8.0
export var radio_energia_entregada:float = 0.1

## Atributos
var nave_player:Player = null
var player_en_zona:bool = false

## Atributos Onready
onready var carga_sfx:AudioStreamPlayer = $CargaSFX
onready var vacio_sfx:AudioStreamPlayer = $VacioSFX
onready var barra_energia:ProgressBar = $BarraEnergia

## Métodos
func _ready() -> void:
	barra_energia.max_value = energia
	barra_energia.value = energia

func _unhandled_input(event: InputEvent) -> void:
		
	if not puede_recargar(event):
		return
	
	controlar_energia()
	
	if event.is_action_pressed("recarga_escudo", true, false):
		nave_player.get_escudo().controlar_energia(radio_energia_entregada)
	elif event.is_action_pressed("recarga_laser", true, false):
		nave_player.get_laser().controlar_energia(radio_energia_entregada)
	
	if event.is_action_released("recarga_laser"):
		Eventos.emit_signal("ocultar_suavizado_energia_laser")
	elif event.is_action_released("recarga_escudo"):
		Eventos.emit_signal("ocultar_energia_escudo")

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("recarga_escudo") or Input.is_action_just_pressed("recarga_laser")) and player_en_zona:
		if energia > 0:
			carga_sfx.play()
		else:
			vacio_sfx.play()
	
	if Input.is_action_just_released("recarga_escudo") or Input.is_action_just_released("recarga_laser"):
		carga_sfx.stop()

## Métodos Custom
func puede_recargar(event:InputEvent) -> bool:
	var hay_input = event.is_action("recarga_escudo") or event.is_action("recarga_laser")
	if hay_input and player_en_zona and energia > 0.0:
		return true
	
	return false

func controlar_energia() -> void:
	energia -= radio_energia_entregada
	barra_energia.value = energia
	if energia <= 0:
		emit_signal("sin_energia")

## Señales Internas
func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()

func _on_AreaRecarga_body_entered(body: Node) -> void:
	if body is Player:
		nave_player = body
		player_en_zona = true
		Eventos.emit_signal("detecto_zona_recarga", true)

func _on_AreaRecarga_body_exited(body: Node) -> void:
	if body is Player:
		player_en_zona = false
		Eventos.emit_signal("ocultar_energia_escudo")
		Eventos.emit_signal("ocultar_suavizado_energia_laser")
		carga_sfx.stop()
		Eventos.emit_signal("detecto_zona_recarga", false)

func _on_EstacionRecarga_sin_energia() -> void:
	carga_sfx.stop()
	vacio_sfx.play()
