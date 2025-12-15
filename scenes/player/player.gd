# player.gd

extends CharacterBody2D

@export var speed: float = 150.0
@export var fire_rate: float = 0.5
@export var bullet_scene: PackedScene
@export var max_health: int = 100
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: Vector2 = Vector2.RIGHT
var current_health: int
var can_take_damage: bool = true # Para implementar invulnerabilidad temporal (i-frames)

func _ready():
	current_health = max_health
	animated_sprite.play("idle")

func _physics_process(_delta):
	# Obtener input del jugador
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalizar para evitar movimiento diagonal más rápido
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		last_direction = input_vector
	
	# Aplicar velocidad
	velocity = input_vector * speed
	
	# Manejar animaciones de movimiento
	if velocity.length() > 0:
		animated_sprite.play("run")
		# Voltear sprite según dirección
		if velocity.x > 0:
			animated_sprite.flip_h = false
		elif velocity.x < 0:
			animated_sprite.flip_h = true
	else:
		# Solo volver a idle si no está en animación de daño
		if animated_sprite.animation != "receivedamage":
			animated_sprite.play("idle")
	
	# Mover el jugador
	move_and_slide()

# Función de ataque del jugador
func _on_fire_timer_timeout():
	if bullet_scene == null:
		return
	
	# Calcular dirección hacia el cursor
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	
	# Disparar la bala hacia el cursor
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.set_direction(shoot_direction)

# Función llamada por los enemigos al colisionar
func take_damage(amount: int):
	if not can_take_damage:
		return
		
	current_health -= amount
	print("Player HP: ", current_health)
	
	if current_health <= 0:
		die()
	else:
		# 1. Iniciar invulnerabilidad temporal
		can_take_damage = false
		$TimerIFrames.start() 
		
		# 2. Ejecutar animación de daño
		if animated_sprite.sprite_frames.has_animation("receivedamage"):
			animated_sprite.play("receivedamage")
			# El _physics_process se encargará de volver a la animación correcta

# Conectada a la señal body_entered del nodo Hurtbox
func _on_hurtbox_body_entered(body):
	# Aseguramos que solo reaccione a los enemigos
	if body.is_in_group("enemy"):
		# Llamamos a la función de daño, usando la variable de daño del enemigo
		take_damage(body.damage)
	
# Conectada a la señal timeout del nodo TimerIFrames
func _on_timer_i_frames_timeout():
	# Después del tiempo, el jugador puede volver a recibir daño
	can_take_damage = true
	# No hace falta detener animación, _physics_process lo maneja.

func die():
	print("Player died!")
	# Detener movimiento y procesamiento
	set_physics_process(false)
	velocity = Vector2.ZERO
	
	# 1. Ejecutar animación de muerte si existe
	if animated_sprite.sprite_frames.has_animation("die"):
		animated_sprite.play("die")
		await animated_sprite.animation_finished
	else:
		# Si no hay animación, mostrar idle y esperar un momento
		animated_sprite.play("idle")
		await get_tree().create_timer(1.0).timeout
	
	# 2. Detener el juego, mostrar Game Over, etc.
	print("Game Over!")
	get_tree().paused = true
	# queue_free() # Opcional: descomentar si quieres destruir al jugador
