class_name ExplosionMeteorito
extends Node2D


onready var animations := $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animations.play(elegir_explosion_aleatoria())
	

func elegir_explosion_aleatoria() -> String:
	randomize()
	var num_anim:int = animations.get_animation_list().size() - 1
	var indice_anim_aleatoria:int = randi() % num_anim + 1
	var lista_anim:Array = animations.get_animation_list()
	
	return lista_anim[indice_anim_aleatoria]

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	queue_free()
