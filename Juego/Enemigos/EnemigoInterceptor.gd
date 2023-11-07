class_name EnemigoInterceptor
extends EnemigoBase


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimacionesInterceptor.play("spawn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

## Señales Internas
func _on_AnimacionesInterceptor_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		controlador_estados(ESTADO.VIVO)
		canion.set_esta_disparando(true)

