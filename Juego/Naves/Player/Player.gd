class_name Player
extends NaveBase

## Atributos export
export var potencia_motor:int = 30
export var potencia_rotacion:int = 200
export var estela_maxima:int = 150

## Atributos
var empuje:Vector2 = Vector2.ZERO
var dir_rotacion:int = 0

## Atributos onready
onready var laser:RayoLaser = $LaserBeam2D setget ,get_laser
onready var estela:Estela = $EstelaPuntoInicio/Trail2D
onready var motor_sfx:Motor = $MotorSFX
onready var escudo:Escudo = $Escudo setget ,get_escudo

## Setters y Getters
func get_laser() -> RayoLaser:
	return laser

func get_escudo() -> Escudo:
	return escudo

## Métodos
func _process(_delta: float) -> void:
	player_input()
	
func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	apply_torque_impulse(dir_rotacion * potencia_rotacion)
	apply_central_impulse(empuje.rotated(rotation))

func _unhandled_input(event: InputEvent) -> void:
	if not esta_input_activo():
		return
			
	# Disparo Rayo
	if event.is_action("disparo_secundario"):
		laser.set_is_casting(true)
	
	if event.is_action_released("disparo_secundario"):
		laser.set_is_casting(false)
	
	# Control Estela
	if event.is_action_pressed("Mover Adelante"):
		estela.set_max_points(estela_maxima)
		motor_sfx.sonido_on()
	elif event.is_action_pressed("Mover atrás"):
		estela.set_max_points(0)
		motor_sfx.sonido_on()
	
	if event.is_action_released("Mover Adelante") or event.is_action_released("Mover atrás"):
		motor_sfx.sonido_off()
		
	# Control escudo
	if event.is_action_pressed("escudo") and not escudo.get_esta_activo():
		escudo.activar()

## Métodos Custom
func player_input() -> void:
	if not esta_input_activo():
		return
		
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

func _on_AnimacionesPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)

