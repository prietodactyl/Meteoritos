extends CanvasLayer

func _ready() -> void:
	visible = false
	get_tree().paused = false

func _input(event):
	if event.is_action_pressed("pause"):
		pause()

func pause():
	get_tree().paused = !get_tree().paused
	activar_mouse()
	visible = !visible

func activar_mouse():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_BotonContinuar_pressed() -> void:
	pause()
	
func _on_BotonReiniciar_pressed() -> void:
	get_tree().reload_current_scene()

func _on_BotonMenu_pressed() -> void:
	get_tree().change_scene("res://Juego/UI/MenuPrincipal.tscn")

func _on_BotonSalir_pressed() -> void:
	get_tree().quit()
