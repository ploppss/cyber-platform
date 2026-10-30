extends Area2D

@export var velocidad: float = 200.0 # <- Pon aquí el valor que prefieras
@export_file("*.tscn") var nivel_1_ruta: String = "res://escenas/levels/Nivel1.tscn"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var jugador: Node2D = null

func _ready() -> void:
	# Conectar la señal de colisión
	body_entered.connect(_on_body_entered)
	# Buscar al jugador en el nivel
	jugador = get_tree().current_scene.find_child("Player", true, false)

func _physics_process(delta: float) -> void:
	if not jugador:
		return

	# Persecución en X (sin importar obstáculos)
	var direccion_x = sign(jugador.global_position.x - global_position.x)
	global_position.x += direccion_x * velocidad * delta

	# Si quieres que también lo siga en altura (Y), descomenta la siguiente línea:
	# global_position.y = move_toward(global_position.y, jugador.global_position.y, velocidad * 0.5 * delta)

	# Voltear el sprite según hacia dónde camina
	if direccion_x != 0:
		sprite.flip_h = direccion_x < 0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Reinicia hasta el Nivel 1
		get_tree().change_scene_to_file(nivel_1_ruta)
