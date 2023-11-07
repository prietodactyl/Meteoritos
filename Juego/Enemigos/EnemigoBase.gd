class_name EnemigoBase
extends NaveBase

## Métodos
func _ready() -> void:
	pass

## Señales Internas
func _on_body_entered(body:Node) -> void:
	._on_body_entered(body)
	if body is Player:
		body.destruir()
		destruir()
