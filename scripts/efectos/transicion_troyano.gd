extends CanvasLayer

signal transicion_terminada

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	visible = false

func reproducir() -> void:
	visible = true
	anim_player.play("Trancision_troyano")
	await anim_player.animation_finished
	transicion_terminada.emit()
