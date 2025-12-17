# enemy_base.gd

extends CharacterBody2D

# Propiedades exportables para variar la dificultad de cada enemigo
@export var max_health: int = 100
@export var speed: float = 120.0
@export var damage: int = 10 # Daño que inflige este enemigo (para futuros ataques)
@export var xp_value: int = 10 # XP que otorga al morir

var current_health: int
var player: Node2D
var health_bar: Node2D  # Barra de vida del enemigo
var is_dying: bool = false # ¡Nueva variable para controlar el estado!
var xp_orb_scene = preload("res://scenes/projectiles/xp_orb.tscn")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Inicializa la vida actual al máximo al inicio
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")
	
	if animated_sprite != null:
		animated_sprite.play("idle")
	
	# Crear barra de vida
	create_health_bar()

func _physics_process(delta):
	# NO hacer nada si está muriendo
	if is_dying:
		return
	
	if player == null:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	if velocity.length() > 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
	
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
		
	move_and_slide()

# Función llamada por el proyectil
func take_damage(amount: int = 1):
	# No recibir daño si ya está muriendo
	if is_dying:
		return
		
	print("Enemigo recibe daño: ", amount)
	current_health -= amount
	print("Vida restante del enemigo: ", current_health)
	
	# Actualizar barra de vida
	if health_bar:
		health_bar.update_health(current_health, max_health)
	
	if current_health <= 0:
		die()
	else:
		# 1. Ejecutar animación de daño (sin bloquear el movimiento)
		if animated_sprite.sprite_frames.has_animation("hurt"):
			animated_sprite.play("hurt")
			# El _physics_process automáticamente retomará la animación de walk/idle

func die():
	is_dying = true
	print("Enemigo murió!")
	
	# Ocultar barra de vida
	if health_bar:
		health_bar.visible = false
	
	# Notificar al jugador sobre el kill
	if player and player.has_method("add_kill"):
		player.add_kill()
	
	# Spawn XP Orb
	if xp_orb_scene:
		var orb = xp_orb_scene.instantiate()
		orb.global_position = global_position
		orb.xp_amount = xp_value
		get_parent().call_deferred("add_child", orb)
	
	# 1. Deshabilitar colisiones y movimiento
	set_collision_mask_value(1, false) 
	set_collision_layer_value(1, false) 
	set_physics_process(false)
	
	# 2. Reproducir animación de muerte si existe (sin bloquear)
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
	
	# 3. Esperar 1.5 segundos para dar feedback visual
	await get_tree().create_timer(1.5).timeout
	
	# 4. Destruir el enemigo
	queue_free()

func create_health_bar():
	var health_bar_script = load("res://scenes/enemies/enemy_health_bar.gd")
	if health_bar_script:
		health_bar = Node2D.new()
		health_bar.set_script(health_bar_script)
		health_bar.z_index = 100
		add_child(health_bar)
		health_bar.update_health(current_health, max_health)

func _on_spawn_timer_timeout() -> void:
	pass # Replace with function body.
