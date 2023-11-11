class_name Canion
extends Node2D


## Atributos
export var proyectil:PackedScene = null
export var cadencia_disparo:float = 0.8
export var velocidad_proyectil:int = 100
export var danio_proyectil:int = 1

## Atributos onready
onready var disparo_sfx:AudioStreamPlayer2D = $DisparoSFX
onready var temporizador := $Timer

## Atributos
var puntos_disparo:Array = []
var esta_enfriado:bool = true
var esta_disparando:bool = false setget set_esta_disparando
var puede_disparar:bool = false setget set_puede_disparar

## Setters y getters
func set_esta_disparando(disparando:bool) -> void:
	esta_disparando = disparando

func set_puede_disparar(duenio_puede: bool) -> void:
	puede_disparar = duenio_puede

## Métodos
func _ready() -> void:
	almacenar_puntos_disparo()
	
func _process(_delta: float) -> void:
	if esta_disparando and esta_enfriado:
		disparar()

## Métodos custom
func almacenar_puntos_disparo() -> void:
	for nodo in get_children():
		if nodo is Position2D:
			puntos_disparo.append(nodo)
			
func disparar() -> void:
	if puede_disparar:
		esta_enfriado = false
		disparo_sfx.play()
		temporizador.start(cadencia_disparo)
		for punto_disparo in puntos_disparo:
			var new_proyectil:Proyectil = proyectil.instance()
			new_proyectil.crear(
				punto_disparo.global_position,
				get_owner().rotation,
				velocidad_proyectil,
				danio_proyectil
			)
			Eventos.emit_signal("disparo", new_proyectil)

func _on_Timer_timeout() -> void:
	esta_enfriado = true
