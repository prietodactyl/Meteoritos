extends Node

export var explosion:PackedScene = null

onready var animador:= $AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	MusicaJuego.play_musica(MusicaJuego.get_lista_musicas().menu_victoria)	

func crear_explosiones(posicion:Vector2,
	num_explosiones:int = 1,
	intervalo:float = 1.0,
	_rangos_aleatorios:Vector2 = Vector2(0.0, 0.0)
	) -> void:
		for _i in range(num_explosiones):
			randomize()
			var rango_aleatorio:float = rand_range(0.75, 1.25)
			var tamanio_explosion:Vector2 = Vector2(rango_aleatorio, rango_aleatorio)
			var new_explosion:Node2D = explosion.instance()
			new_explosion.global_position = posicion
			new_explosion.scale = tamanio_explosion
			add_child(new_explosion)
			yield(get_tree().create_timer(intervalo), "timeout")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "disparo":
		crear_explosiones(Vector2(1500, 775), 2, 0.8)
		animador.play("avance")
	else:
		animador.play("disparo")

func _on_BotonMenu_pressed() -> void:
	get_tree().change_scene("res://Juego/UI/MenuPrincipal.tscn")

func _on_BotonSalir_pressed() -> void:
	get_tree().quit()
