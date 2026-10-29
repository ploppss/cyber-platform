extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Multiplicador de velocidad horizontal (lo modifica el efecto Adware).
var velocidad_mult: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $PJanimation

func set_velocidad_mult(valor: float) -> void:
	velocidad_mult = valor

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movimiento horizontal
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED * velocidad_mult
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	revisar_anuncios()
	update_animation(direction)


# Si el jugador toca un nodo del grupo "anuncios", activa el efecto Adware.
func revisar_anuncios() -> void:
	for i in get_slide_collision_count():
		var otro := get_slide_collision(i).get_collider() as Node
		if otro and otro.is_in_group("anuncios"):
			get_tree().call_group("adware", "activar", self)
			return


func update_animation(direction: float):
	if not is_on_floor():
		# aquí luego puedes meter una animación de salto/caída si haces sprites nuevos
		pass
	elif direction != 0:
		animated_sprite.flip_h = direction < 0
		if animated_sprite.animation != "run":
			animated_sprite.play("run")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
