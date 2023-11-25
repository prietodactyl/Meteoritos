extends MarginContainer

## Atributos Export
export var escala_zoom:float = 4.0
export var tiempo_visible:float = 5.0

## Atributos Onready
onready var cuadro_minimap:NinePatchRect = $CuadroMinimap
onready var zona_renderizado:TextureRect = $CuadroMinimap/ContenedorIconos/ZonaRenderizado
onready var icono_player:Node2D = $CuadroMinimap/ContenedorIconos/ZonaRenderizado/IconoPlayer
onready var icono_base_enemiga:Node2D = $CuadroMinimap/ContenedorIconos/ZonaRenderizado/IconoBaseEnemiga
onready var icono_estacion_recarga:Node2D = $CuadroMinimap/ContenedorIconos/ZonaRenderizado/IconoEstacionRecarga
onready var icono_interceptor:Node2D = $CuadroMinimap/ContenedorIconos/ZonaRenderizado/IconoInterceptor
onready var icono_rele:Node2D = $CuadroMinimap/ContenedorIconos/ZonaRenderizado/IconoRele
onready var items_minimap:Dictionary = {}
onready var timer_visibilidad:Timer = $TimerVisibilidad
onready var tween_visibilidad:Tween = $TweenVisibilidad

## Atributos
var escala_grilla:Vector2
var player:Player = null
var esta_visible:bool = true setget set_esta_visible

## Setters y Getters
func set_esta_visible(hacer_visible:bool) -> void:
	if hacer_visible:
		timer_visibilidad.start()
	
	esta_visible = hacer_visible
	
	tween_visibilidad.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, not hacer_visible),
		Color(1, 1, 1, hacer_visible),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween_visibilidad.start()

## Métodos
func _ready() -> void:
	set_process(false)
	timer_visibilidad.start()
	icono_player.position = zona_renderizado.rect_size * 0.5
	escala_grilla = zona_renderizado.rect_size / (get_viewport_rect().size * escala_zoom)
	conectar_seniales()

func _process(_delta:float) -> void:
	if not player:
		return
	
	icono_player.rotation_degrees = player.rotation_degrees + 90
	modificar_posicion_iconos()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("minimap"):
		set_esta_visible(not esta_visible)

## Métodos Custom
func _on_nivel_iniciado() -> void:
	player = DatosJuego.get_player_actual()
	obtener_objetos_minimap()
	set_process(true)

func _on_nave_destruida(nave:NaveBase, _posicion, _explosiones) -> void:
	if nave is Player:
		player = null

func obtener_objetos_minimap() -> void:
	var objetos_en_ventana:Array = get_tree().get_nodes_in_group("minimap")
	for objeto in objetos_en_ventana:
		if not items_minimap.has(objeto):
			var sprite_icono:Node2D
			if objeto is BaseEnemiga:
				sprite_icono = icono_base_enemiga.duplicate()
			elif objeto is EstacionRecarga:
				sprite_icono = icono_estacion_recarga.duplicate()
			elif objeto is EnemigoInterceptor:
				sprite_icono = icono_interceptor.duplicate()
			elif objeto is ReleDeMasa:
				sprite_icono = icono_rele.duplicate()
			
			items_minimap[objeto] = sprite_icono
			items_minimap[objeto].visible = true
			zona_renderizado.add_child(items_minimap[objeto])

func modificar_posicion_iconos() -> void:
	for item in items_minimap:
		var item_icono:Node2D = items_minimap[item]
		var offset_pos:Vector2 = item.position - player.position
		var pos_icono:Vector2 = offset_pos * escala_grilla + icono_player.position
		pos_icono.x = clamp(pos_icono.x, -3, cuadro_minimap.rect_size.x - 6)
		pos_icono.y = clamp(pos_icono.y, -3, cuadro_minimap.rect_size.y - 6)
		item_icono.position = pos_icono
	
		if zona_renderizado.get_rect().has_point(pos_icono):
			item_icono.scale = Vector2(1, 1)
		else:
			item_icono.scale = Vector2(0.7, 0.7)

func conectar_seniales():
	Eventos.connect("nivel_iniciado", self, "_on_nivel_iniciado")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	Eventos.connect("minimap_objeto_creado", self, "obtener_objetos_minimap")
	Eventos.connect("minimap_objeto_destruido", self, "quitar_icono")

func quitar_icono(objeto:Node2D) -> void:
	if objeto in items_minimap:
		items_minimap[objeto].queue_free()
		items_minimap.erase(objeto)

## Señales Internas
func _on_TimerVisibilidad_timeout() -> void:
	if esta_visible:
		set_esta_visible(false)
