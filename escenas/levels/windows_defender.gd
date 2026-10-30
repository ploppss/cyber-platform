extends Area2D

# Si ya tienes una escena de victoria, pon su ruta aquí
@export_file("*.tscn") var escena_victoria: String = "res://escenas/Victoria.tscn"

var ganado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not ganado:
		ganado = true
		print("¡Juego Ganado!")
		
		# 1. Congelar al jugador y al gladiador para que no te mate al final
		body.set_physics_process(false)
		var gladiador = get_tree().current_scene.find_child("Gladiador", true, false)
		if gladiador:
			gladiador.set_physics_process(false)
		
		# 2. Ir a victoria (o reiniciar si no tienes pantalla aún)
		if escena_victoria != "":
			get_tree().change_scene_to_file("res://escenas/effects/Victoria.tscn")
