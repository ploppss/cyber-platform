extends CanvasLayer
## Efecto ADWARE (simulado). Vive como un nodo CanvasLayer dentro de Nivel2.
##
## Cuando el jugador choca con un anuncio (grupo "anuncios"), player.gd llama
## a activar(). Mientras dura el efecto:
##   - se "espamean" ventanas de adware (Window1_1 a Window1_4) en posiciones al azar,
##   - el jugador se mueve más lento (la "PC va lenta"),
##   - la "X" roja de la ventana (esquina superior derecha) la cierra con clic izquierdo;
##     si clic_multiplica = true, hacer clic en el cuerpo del anuncio abre más
##     (así empeora, como en el adware real).
## Todo es ficticio: no hay conexiones ni descargas reales.

@export var duracion: float = 10.0               ## segundos que dura el efecto
@export var intervalo_popup: float = 0.7         ## cada cuántos segundos aparece una ventana
@export var max_popups: int = 10                 ## máximo de ventanas simultáneas
@export_range(0.1, 1.0) var multiplicador_velocidad: float = 0.5
@export var cooldown: float = 2.0                ## pausa antes de poder activarse otra vez
@export var escala_min: int = 2                  ## las ventanas son de 32x32: escala entera = pixel art nítido
@export var escala_max: int = 3
@export var zona_cerrar: Rect2 = Rect2(24, 6, 5, 4)  ## la "X" roja, en píxeles de la imagen de 32x32 (x, y, ancho, alto)
@export var clic_multiplica: bool = false        ## true: hacer clic en el cuerpo de la ventana (no en la X) abre 2 más y alarga el efecto
@export var tamano_fuente: int = 10

# Las 4 ventanas de adware. (Window1_5 es para otra cosa y no se usa aquí.)
const RUTAS_VENTANAS: Array[String] = [
	"res://recursos/environment/Nivel2/Window1_1.png",
	"res://recursos/environment/Nivel2/Window1_2.png",
	"res://recursos/environment/Nivel2/Window1_3.png",
	"res://recursos/environment/Nivel2/Window1_4.png",
]

var activo: bool = false
var _enfriando: bool = false
var _tiempo_restante: float = 0.0
var _tiempo_spawn: float = 0.0
var _jugador: Node = null
var _texturas: Array[Texture2D] = []
var _popups: Array[Control] = []
var _raiz: Control
var _hud: Label


func _ready() -> void:
	layer = 10  # por encima de todo el juego

	for ruta in RUTAS_VENTANAS:
		if ResourceLoader.exists(ruta):
			_texturas.append(load(ruta) as Texture2D)
		else:
			push_warning("Adware: no existe la imagen " + ruta)

	var tema := Theme.new()
	tema.default_font_size = tamano_fuente

	# Control raíz que ocupa toda la pantalla; no intercepta el mouse.
	_raiz = Control.new()
	_raiz.theme = tema
	_raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_raiz)
	_raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Aviso fijo arriba mientras el efecto está activo.
	_hud = Label.new()
	_hud.position = Vector2(4, 2)
	_hud.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	_hud.add_theme_color_override("font_outline_color", Color.BLACK)
	_hud.add_theme_constant_override("outline_size", 3)
	_hud.visible = false
	_raiz.add_child(_hud)

	# Las ventanas de adware (Area2D del grupo "anuncios") no chocan con el jugador:
	# él las atraviesa y al entrar se activa el efecto. Aquí las conectamos todas solas,
	# así que cualquier Area2D que metas al grupo "anuncios" funciona sin más.
	for nodo in get_tree().get_nodes_in_group("anuncios"):
		if nodo is Area2D:
			nodo.body_entered.connect(_on_anuncio_body_entered)


func _on_anuncio_body_entered(body: Node2D) -> void:
	# Las plataformas (StaticBody2D) también disparan body_entered: solo nos importa el jugador.
	if body.name == "Player":
		activar(body)


func activar(jugador: Node = null) -> void:
	if activo or _enfriando:
		return
	activo = true
	_jugador = jugador
	_tiempo_restante = duracion
	_tiempo_spawn = 0.0
	if is_instance_valid(_jugador) and _jugador.has_method("set_velocidad_mult"):
		_jugador.set_velocidad_mult(multiplicador_velocidad)
	_hud.visible = true
	_crear_popup()


func _process(delta: float) -> void:
	if not activo:
		return

	_tiempo_restante -= delta
	_hud.text = "ADWARE ACTIVO: %d s" % ceili(maxf(_tiempo_restante, 0.0))

	_tiempo_spawn += delta
	if _tiempo_spawn >= intervalo_popup:
		_tiempo_spawn = 0.0
		if _popups.size() < max_popups:
			_crear_popup()

	if _tiempo_restante <= 0.0:
		_desactivar()


func _desactivar() -> void:
	activo = false
	for popup in _popups:
		if is_instance_valid(popup):
			popup.queue_free()
	_popups.clear()
	_hud.visible = false
	if is_instance_valid(_jugador) and _jugador.has_method("set_velocidad_mult"):
		_jugador.set_velocidad_mult(1.0)

	_enfriando = true
	await get_tree().create_timer(cooldown).timeout
	_enfriando = false


func _crear_popup() -> void:
	if _texturas.is_empty():
		return

	var pantalla := get_viewport().get_visible_rect().size
	var textura: Texture2D = _texturas.pick_random()
	var escala := randi_range(escala_min, escala_max)
	var tam := Vector2(textura.get_size()) * escala

	var popup := TextureRect.new()
	popup.texture = textura
	popup.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	popup.stretch_mode = TextureRect.STRETCH_SCALE
	popup.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	popup.custom_minimum_size = tam
	popup.size = tam
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	popup.position = Vector2(
		randf_range(0.0, maxf(pantalla.x - tam.x, 0.0)),
		randf_range(0.0, maxf(pantalla.y - tam.y, 0.0))
	)
	popup.set_meta("escala", escala)
	popup.gui_input.connect(_on_popup_input.bind(popup))
	_raiz.add_child(popup)
	_popups.append(popup)

	# Pequeña animación de "pop" al aparecer.
	popup.pivot_offset = tam / 2.0
	popup.scale = Vector2(0.3, 0.3)
	create_tween().tween_property(popup, "scale", Vector2.ONE, 0.12)


func _on_popup_input(evento: InputEvent, popup: Control) -> void:
	if not (evento is InputEventMouseButton and evento.pressed and evento.button_index == MOUSE_BUTTON_LEFT):
		return

	# Pasamos la posición del clic a píxeles de la imagen original (sin escalar).
	var escala: int = popup.get_meta("escala", 1)
	var pos_imagen: Vector2 = evento.position / float(escala)

	if zona_cerrar.has_point(pos_imagen):
		_cerrar_popup(popup)  # clic en la "X" roja
	elif clic_multiplica:
		# Hacer clic en el cuerpo del anuncio empeora todo: más ventanas y más tiempo.
		_tiempo_restante = minf(_tiempo_restante + 2.0, duracion * 2.0)
		_crear_popup()
		_crear_popup()


func _cerrar_popup(popup: Control) -> void:
	_popups.erase(popup)
	if is_instance_valid(popup):
		popup.queue_free()
