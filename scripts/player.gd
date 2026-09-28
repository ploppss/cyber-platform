extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $PJanimation

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
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_animation(direction)


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
