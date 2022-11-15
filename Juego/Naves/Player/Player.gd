class_name Player
extends RigidBody2D

## Atributos export
export var potencia_motor:int = 20
export var potencia_rotacion:int = 280

## Atributos
var empuje:Vector2 = Vector2.ZERO
var dir_rotacion:int = 0

## Atributos onready
onready var canion:Canion = $Canion

## Métodos
func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	apply_torque_impulse(dir_rotacion * potencia_rotacion)
	apply_central_impulse(empuje.rotated(rotation))

func _process(delta: float) -> void:
	player_input()
	
## Métodos Custom
func player_input() -> void:
	# Empuje
	empuje = Vector2.ZERO
	if Input.is_action_pressed("Mover Adelante"):
		empuje = Vector2(potencia_motor, 0)
	elif Input.is_action_pressed("Mover atrás"):
		empuje = Vector2(-potencia_motor, 0)
	
	# Rotación
	dir_rotacion = 0
	if Input.is_action_pressed("Rotar Antihorario"):
		dir_rotacion -= 1
	elif Input.is_action_pressed("Rotar Horario"):
		dir_rotacion += 1

	# Disparo
	if Input.is_action_pressed("disparo_principal"):
		canion.set_esta_disparando(true)
	
	if Input.is_action_just_released("disparo_principal"):
		canion.set_esta_disparando(false)
