class_name Nivel
extends Node2D

## Atributos export
export(String, FILE, "*.tscn") var prox_nivel = ""
export var tiempo_limite:int = 10
export var tiempo_transicion_camara:float = 2.0
export var tiempo_bonus:int = 5
export var explosion:PackedScene = null
export var meteorito:PackedScene = null
export var explosion_meteorito:PackedScene = null
export var sector_meteoritos:PackedScene = null
export var enemigo_interceptor:PackedScene = null
export var rele_masa:PackedScene = null
export var musica_nivel:AudioStream = null
export var musica_combate:AudioStream = null

## Atributos
var meteoritos_totales: int = 0
var player:Player = null
var numero_bases_enemigas:int = 0

## Atributos Onready
onready var contenedor_proyectiles:Node
onready var contenedor_meteoritos:Node
onready var contenedor_sector_meteoritos:Node
onready var camara_nivel:Camera2D = $CamaraNivel
onready var camara_player:Camera2D = $Player/CamaraPlayer
onready var contenedor_enemigos:Node
onready var contenedor_bases_enemigas:Node = $ContenedorBasesEnemigas
onready var actualizador_timer:Timer = $ActualizadorTimer

## Métodos
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	MusicaJuego.set_streams(musica_nivel, musica_combate)
	MusicaJuego.play_musica_nivel()
	conectar_seniales()
	crear_contenedores()
	player = DatosJuego.get_player_actual()
	numero_bases_enemigas = contabilizar_bases_enemigas()
	actualizador_timer.start()
	Eventos.emit_signal("nivel_iniciado")
	Eventos.emit_signal("actualizar_tiempo_restante", tiempo_limite)
	
## Métodos Custom
func conectar_seniales() -> void:
	Eventos.connect("disparo", self, "_on_disparo")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	Eventos.connect("spawn_meteorito", self, "_on_spawn_meteorito")
	Eventos.connect("meteorito_destruido", self, "_on_meteorito_destruido")
	Eventos.connect("nave_en_sector_peligro", self, "_on_nave_en_sector_peligro")
	Eventos.connect("base_destruida", self, "_on_base_destruida")
	Eventos.connect("spawn_orbital", self, "_on_spawn_orbital")
	Eventos.connect("nivel_completado", self, "_on_nivel_completado")
	
func crear_contenedores() -> void:
	contenedor_proyectiles = Node.new()
	contenedor_proyectiles.name = "ContenedorProyectiles"
	add_child(contenedor_proyectiles)
	contenedor_meteoritos = Node.new()
	contenedor_meteoritos.name = "ContenedorMeteoritos"
	add_child(contenedor_meteoritos)
	contenedor_sector_meteoritos = Node.new()
	contenedor_sector_meteoritos.name = "ContenedorSectorMeteoritos"
	add_child(contenedor_sector_meteoritos)
	contenedor_enemigos = Node.new()
	contenedor_enemigos.name = "ContenedorEnemigos"
	add_child(contenedor_enemigos)

func crear_sector_meteoritos(centro_camara:Vector2, numero_peligros:int) -> void:
	MusicaJuego.transicion_musicas()
	camara_nivel.global_position = centro_camara
	meteoritos_totales = numero_peligros
	var new_sector_meteoritos:SectorMeteoritos = sector_meteoritos.instance()
	new_sector_meteoritos.crear(centro_camara, numero_peligros)
	contenedor_sector_meteoritos.add_child(new_sector_meteoritos)
	camara_nivel.zoom = camara_player.zoom
	camara_nivel.devolver_zoom_original()
	transicion_camaras(
		camara_player.global_position,
		camara_nivel.global_position,
		camara_nivel,
		tiempo_transicion_camara
	)
	Eventos.emit_signal("cambio_numero_meteoritos", meteoritos_totales)

func crear_sector_enemigos(num_enemigos:int) -> void:
	for _i in range(num_enemigos):
		var new_interceptor:EnemigoInterceptor = enemigo_interceptor.instance()
		var pos_spawn:Vector2 = crear_posicion_aleatoria(1000.0, 800.0)
		new_interceptor.global_position = player.global_position + pos_spawn
		contenedor_enemigos.add_child(new_interceptor)

func transicion_camaras(desde:Vector2, hasta:Vector2, camara_actual:Camera2D, tiempo_transicion:float) -> void:
	$TweenCamara.interpolate_property(
		camara_actual,
		"global_position",
		desde,
		hasta,
		tiempo_transicion,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	camara_actual.current = true
	$TweenCamara.start()
		
func controlar_meteoritos_restantes() -> void:
	meteoritos_totales -= 1
	Eventos.emit_signal("cambio_numero_meteoritos", meteoritos_totales)
	if meteoritos_totales == 0:
		MusicaJuego.transicion_musicas()
		Eventos.emit_signal("sector_meteoritos_finalizado")
		contenedor_sector_meteoritos.get_child(0).queue_free()
		camara_player.set_puede_hacer_zoom(true)
		var zoom_actual = camara_player.zoom
		camara_player.zoom = camara_nivel.zoom
		camara_player.zoom_suavizado(zoom_actual.x, zoom_actual.y, 1.0)
		transicion_camaras(
			camara_nivel.global_position,
			camara_player.global_position,
			camara_player,
			tiempo_transicion_camara * 0.10
		)

func crear_posicion_aleatoria(rango_horizontal:float, rango_vertical:float) -> Vector2:
	randomize()
	var rand_x = rand_range(-rango_horizontal, rango_horizontal)
	var rand_y = rand_range(-rango_vertical, rango_vertical)
	
	return Vector2(rand_x, rand_y)

func crear_explosiones(posicion:Vector2,
	num_explosiones:int = 1,
	intervalo:float = 1.0,
	rangos_aleatorios:Vector2 = Vector2(0.0, 0.0)
	) -> void:
		for _i in range(num_explosiones):
			randomize()
			var rango_aleatorio:float = rand_range(0.75, 1.25)
			var tamanio_explosion:Vector2 = Vector2(rango_aleatorio, rango_aleatorio)
			var new_explosion:Node2D = explosion.instance()
			new_explosion.global_position = posicion + crear_posicion_aleatoria(
				rangos_aleatorios.x,
				rangos_aleatorios.y
			)
			new_explosion.scale = tamanio_explosion
			add_child(new_explosion)
			yield(get_tree().create_timer(intervalo),"timeout")

func contabilizar_bases_enemigas() -> int:
	return contenedor_bases_enemigas.get_child_count()

func crear_rele() -> void:	
	var new_rele_masa:ReleDeMasa = rele_masa.instance()
	new_rele_masa.global_position = crear_posicion_aleatoria_rele()
	add_child(new_rele_masa)

func crear_posicion_aleatoria_rele() -> Vector2:
	randomize()
	var theta:float = randf() * 2 * PI
	return player.global_position + Vector2(cos(theta), sin(theta)) * rand_range(650, 1000)

func destruir_nivel() -> void:
	crear_explosiones(player.global_position, 8, 2.0, Vector2(300.0, 200.0))
	player.destruir()

func _on_nivel_completado() -> void:
	Eventos.emit_signal("nivel_terminado")
	yield(get_tree().create_timer(1.0),"timeout")
	get_tree().change_scene(prox_nivel)

## Señales Internas
func _on_TweenCamara_tween_completed(object: Object, _key: NodePath) -> void:
	if object.name == "CamaraPlayer":
		object.global_position = $Player.global_position

func _on_RestartTimer_timeout() -> void:
	Eventos.emit_signal("nivel_terminado")
	yield(get_tree().create_timer(1.0),"timeout")
	get_tree().reload_current_scene()

func _on_ActualizadorTimer_timeout() -> void:
	tiempo_limite -= 1
	Eventos.emit_signal("actualizar_tiempo_restante", tiempo_limite)
	if tiempo_limite == 0:
		destruir_nivel()
		
## Conexión Señales Externas
func _on_disparo(proyectil:Proyectil) -> void:
	contenedor_proyectiles.add_child(proyectil)

func _on_nave_destruida(nave:NaveBase, posicion:Vector2, num_explosiones: int) -> void:
	if nave is Player:
		player = null
		transicion_camaras(
			posicion,
			posicion + crear_posicion_aleatoria(200.0, 200.0),
			camara_nivel,
			tiempo_transicion_camara
		)
		
		$RestartTimer.start()
		
	if nave is EnemigoInterceptor:
		tiempo_limite += tiempo_bonus
		
	crear_explosiones(posicion, num_explosiones, 0.6, Vector2(100.0, 50.0))


func _on_spawn_meteorito(pos_spawn: Vector2, dir_meteorito:Vector2, tamanio:float) -> void:
	var new_meteorito:Meteorito = meteorito.instance()
	new_meteorito.crear(
		pos_spawn,
		dir_meteorito,
		tamanio
	)	
	contenedor_meteoritos.add_child(new_meteorito)

func _on_meteorito_destruido(pos: Vector2) -> void:
	tiempo_limite += tiempo_bonus
	var new_explosion: ExplosionMeteorito = explosion_meteorito.instance()
	new_explosion.global_position = pos
	add_child(new_explosion)
	
	controlar_meteoritos_restantes()

func _on_nave_en_sector_peligro(centro_cam:Vector2, tipo_peligro:String, num_peligros:int) -> void:
	if tipo_peligro == "Meteorito":
		crear_sector_meteoritos(centro_cam, num_peligros)
		Eventos.emit_signal("cambio_numero_meteoritos", num_peligros)
	elif tipo_peligro == "Enemigo":
		crear_sector_enemigos(num_peligros)

func _on_base_destruida(_base, pos_partes:Array) -> void:
	for pos in pos_partes:
		crear_explosiones(pos)
		yield(get_tree().create_timer(0.5),"timeout")
	
	numero_bases_enemigas -= 1
	if numero_bases_enemigas == 0 and player:
		actualizador_timer.stop()
		crear_rele()

func _on_spawn_orbital(enemigo:EnemigoOrbital) -> void:
	contenedor_enemigos.add_child(enemigo)


