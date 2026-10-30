extends Area2D

# Configuración desde el Inspector
@export_file("*.tscn") var siguiente_escena: String = ""
@export var tiempo_espera: float = 3.0

# Arrastra aquí la transición correspondiente de cada nivel
@export var pantalla_carga: CanvasLayer

var activado: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not activado:
		activado = true
		_iniciar_transicion(body)

func _iniciar_transicion(player: Node2D) -> void:
	# 1. Congelar físicas y movimiento
	player.set_physics_process(false)
	if "velocity" in player:
		player.velocity = Vector2.ZERO

	# 2. Reproducir según el tipo de transición
	if pantalla_carga:
		if pantalla_carga.has_method("reproducir"):
			# Nivel 2: Es la cinemática del troyano
			pantalla_carga.reproducir()
			await pantalla_carga.transicion_terminada
		else:
			# Nivel 1: Transición normal por tiempo
			pantalla_carga.visible = true
			await get_tree().create_timer(tiempo_espera).timeout

	# 3. Cambiar de escena
	if siguiente_escena != "":
		get_tree().change_scene_to_file(siguiente_escena)
