class_name Player
extends RigidBody2D

## Enums
enum ESTADO{SPAWN, VIVO, INVENCIBLE, MUERTO}

## Atributos export
export var potencia_motor:int = 20
export var potencia_rotacion:int = 280
export var estela_maxima:int = 150

## Atributos
var empuje:Vector2 = Vector2.ZERO
var dir_rotacion:int = 0
var estado_actual:int = ESTADO.SPAWN

## Atributos onready
onready var canion:Canion = $Canion
onready var laser:RayoLaser = $LaserBeam2D
onready var estela:Estela = $EstelaPuntoInicio/Trail2D
onready var motor_sfx:Motor = $MotorSFX
onready var colisionador:CollisionShape2D = $CollisionShape2D

## Señales internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)
	
## Métodos
func _ready() -> void:
	pass

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	apply_torque_impulse(dir_rotacion * potencia_rotacion)
	apply_central_impulse(empuje.rotated(rotation))

func _process(delta: float) -> void:
	player_input()

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
	
## Métodos Custom
func controlador_estados(nuevo_estado:int) -> void:
	match nuevo_estado:
		ESTADO.SPAWN:
			colisionador.set_deferred("disabled", true)
			canion.set_puede_disparar(false)
		ESTADO.VIVO:
			colisionador.set_deferred("disabled", false)
			canion.set_puede_disparar(true)
		ESTADO.INVENCIBLE:
			colisionador.set_deferred("disabled", true)
		ESTADO.MUERTO:
			colisionador.set_deferred("disabled", true)
			canion.set_puede_disparar(false)
			Eventos.emit_signal("nave_destruida", global_position, 3)
			queue_free()
		_:
			printerr("Error de estado")
	
	estado_actual = nuevo_estado

func esta_input_activo() -> bool:
	if estado_actual in [ESTADO.MUERTO, ESTADO.SPAWN]:
		return false
	return true

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

func destruir() -> void:
	controlador_estados(ESTADO.MUERTO)
