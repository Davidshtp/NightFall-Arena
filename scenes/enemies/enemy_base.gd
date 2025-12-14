# enemy_base.gd

extends CharacterBody2D

@export var speed: float = 120.0

var player: Node2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Obtenemos una referencia al nodo

func _ready():
	# Buscamos al jugador por grupo
	player = get_tree().get_first_node_in_group("player")
	# Inicia la animación por defecto (idle)
	animated_sprite.play("idle") # Asegúrate de que el nombre de la animación sea 'idle'

func _physics_process(delta):
	if player == null:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	# 1. Animación de correr
	if velocity.length() > 0:
		animated_sprite.play("walk") # O "run", según cómo la hayas llamado
	else:
		animated_sprite.play("idle")

	# 2. Volteo (Flip) para mirar al jugador
	if direction.x > 0:
		animated_sprite.flip_h = false # Mira a la derecha
	elif direction.x < 0:
		animated_sprite.flip_h = true # Mira a la izquierda
		
	move_and_slide()

func take_damage():
	# Eliminación temporal
	queue_free()
