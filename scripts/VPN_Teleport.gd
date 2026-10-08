extends Area2D

# Ruta a la escena del siguiente nivel (configurable desde el Inspector)
@export_file("*.tscn") var siguiente_escena: String = ""

# Tiempo que permanece visible la pantalla de transición
@export var tiempo_espera: float = 5.0

# Referencia a la pantalla de carga (CanvasLayer)
@onready var pantalla_carga: CanvasLayer = $"../TransicionServidor"

var activado: bool = false

func _on_body_entered(body: Node2D) -> void:
	# Comprobar que sea el jugador y evitar que se dispare más de una vez
	if body.name == "Player" and not activado:
		activado = true
		_iniciar_transicion(body)

func _iniciar_transicion(player: Node2D) -> void:
	# 1. Congelar físicas y movimiento del jugador
	player.set_physics_process(false)
	if "velocity" in player:
		player.velocity = Vector2.ZERO
	
	# 2. Hacer visible la pantalla de carga
	pantalla_carga.visible = true
	
	# 3. Esperar el tiempo establecido
	await get_tree().create_timer(tiempo_espera).timeout
	
	# 4. Cambiar a la siguiente escena si hay una asignada
	if siguiente_escena != "":
		get_tree().change_scene_to_file(siguiente_escena)
