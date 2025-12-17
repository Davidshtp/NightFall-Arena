# xp_orb.gd - Sistema de XP estilo Minecraft

extends Area2D

@export var xp_amount: int = 10
@export var initial_jump_force: float = 150.0
@export var gravity_force: float = 400.0
@export var attraction_distance: float = 80.0
@export var attraction_speed: float = 200.0
@export var bounce_dampening: float = 0.5

var velocity: Vector2 = Vector2.ZERO
var is_grounded: bool = false
var player: Node2D = null
var can_collect: bool = false
var float_time: float = 0.0

func _ready():
	# Salto inicial aleatorio al spawnear (como Minecraft)
	var random_angle = randf_range(-PI/3, PI/3)  # Ángulo aleatorio
	velocity = Vector2(
		sin(random_angle) * initial_jump_force * randf_range(0.5, 1.0),
		-initial_jump_force * randf_range(0.8, 1.2)
	)
	
	# Pequeño delay antes de poder recogerlo
	await get_tree().create_timer(0.3).timeout
	can_collect = true
	
	# Buscar al jugador
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	# Aplicar gravedad
	if not is_grounded:
		velocity.y += gravity_force * delta
		
		# Simular colisión con el suelo (altura límite)
		if position.y > 0:
			position.y = 0
			velocity.y = -velocity.y * bounce_dampening
			if abs(velocity.y) < 20:
				is_grounded = true
				velocity = Vector2.ZERO
	
	# Movimiento horizontal con fricción
	velocity.x *= 0.98
	
	# Movimiento flotante cuando está en el suelo
	if is_grounded:
		float_time += delta * 3.0
		position.y = sin(float_time) * 2.0  # Pequeño movimiento flotante
	
	# Atracción hacia el jugador si está cerca
	if player and player.is_inside_tree() and can_collect:
		var distance = global_position.distance_to(player.global_position)
		if distance < attraction_distance:
			var direction = (player.global_position - global_position).normalized()
			var attraction_force = (1.0 - distance / attraction_distance) * attraction_speed
			velocity = direction * attraction_force * 2.0
			is_grounded = false  # Permitir que se mueva hacia el jugador
	
	# Aplicar movimiento
	position += velocity * delta
	
	# Efecto de escala pulsante
	var pulse = 1.0 + sin(float_time * 2.0) * 0.1
	scale = Vector2(pulse, pulse) * 0.2

func _on_body_entered(body):
	if not can_collect:
		return
		
	if body.is_in_group("player"):
		if body.has_method("gain_xp"):
			body.gain_xp(xp_amount)
		
		# Pequeño efecto visual al recoger (opcional: añadir partículas)
		queue_free()
