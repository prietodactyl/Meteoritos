extends Area2D

## Atributos Export
export(String, "vacio", "Meteorito", "Enemigo") var tipo_peligro
export var numero_peligros:int = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Señales
func _on_body_entered(_body: Node) -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	enviar_senial()

func enviar_senial() -> void:	
	Eventos.emit_signal(
		"nave_en_sector_peligro",
		$PosicionCentroSector.global_position,
		tipo_peligro,
		numero_peligros
	)
	
	queue_free()
