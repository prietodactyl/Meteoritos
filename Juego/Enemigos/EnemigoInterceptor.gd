class_name EnemigoInterceptor
extends EnemigoBase

## Enums
enum ESTADO_IA {IDLE, ATACANDOQ, ATACANDOP, PERSECUCION}

## Atributos Export
export var potencia_max:float = 800.0

## Atributos
var estado_ia_actual:int = ESTADO_IA.IDLE
var potencia_actual:float = 0.0
var puede_cambiar_estado:bool = false

## Métodos
func _ready() -> void:
	controlador_estados_ia(ESTADO_IA.IDLE)
	$AnimacionesInterceptor.play("spawn")

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	linear_velocity += dir_player.normalized() * potencia_actual * state.get_step()
	
	linear_velocity.x = clamp(linear_velocity.x, -potencia_max, potencia_max)
	linear_velocity.y = clamp(linear_velocity.y, -potencia_max, potencia_max)

## Métodos Custom
func controlador_estados_ia(nuevo_estado:int) -> void:
	match nuevo_estado:
		ESTADO_IA.IDLE:
			canion.set_esta_disparando(false)
			potencia_actual = 0.0
		ESTADO_IA.ATACANDOQ:
			canion.set_esta_disparando(true)
			potencia_actual = 0.0
			ralentizar()
		ESTADO_IA.ATACANDOP:
			canion.set_esta_disparando(true)
			potencia_actual = potencia_max
		ESTADO_IA.PERSECUCION:
			canion.set_esta_disparando(false)
			potencia_actual = potencia_max
		_:
			printerr("Error de estado")
	
	estado_ia_actual = nuevo_estado

func ralentizar() -> void:
	$TweenMovimiento.interpolate_property(
		self,
		"linear_velocity",
		linear_velocity,
		crear_velocidad_aleatoria(60, 60),
		1.8,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$TweenMovimiento.start()

func crear_velocidad_aleatoria(rango_horizontal:float, rango_vertical:float) -> Vector2:
	randomize()
	var rand_x = rand_range(-rango_horizontal, rango_horizontal)
	var rand_y = rand_range(-rango_vertical, rango_vertical)
	
	return Vector2(rand_x, rand_y)

## Señales Internas
func _on_AnimacionesInterceptor_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)
		puede_cambiar_estado = true
		controlador_estados_ia(ESTADO_IA.PERSECUCION)
		

func _on_AreaDisparo_body_entered(_body: Node) -> void:
	if puede_cambiar_estado:
		controlador_estados_ia(ESTADO_IA.ATACANDOQ)

func _on_AreaDisparo_body_exited(_body: Node) -> void:
	if puede_cambiar_estado:
		controlador_estados_ia(ESTADO_IA.ATACANDOP)

func _on_AreaDeteccion_body_entered(_body: Node) -> void:
	if puede_cambiar_estado:
		controlador_estados_ia(ESTADO_IA.ATACANDOP)

func _on_AreaDeteccion_body_exited(_body: Node) -> void:
	if puede_cambiar_estado:
		controlador_estados_ia(ESTADO_IA.PERSECUCION)
