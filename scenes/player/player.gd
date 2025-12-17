# player.gd

extends CharacterBody2D

@export var speed: float = 150.0
@export var fire_rate: float = 0.5
@export var bullet_scene: PackedScene
@export var max_health: int = 100
@export var game_over_scene: PackedScene
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var health_bar
var hud: Node  # Referencia al HUD
var last_direction: Vector2 = Vector2.RIGHT
var current_health: int
var can_take_damage: bool = true
var is_dead: bool = false

var survival_time: float = 0.0
var kill_count: int = 0
var current_xp: int = 0
var current_level: int = 1

# Sistema de niveles - XP necesaria para subir
var xp_thresholds: Array[int] = [70, 140, 210]  # Nivel 2, 3, 4

# Sistema de mejoras
var has_triple_shot: bool = false
var triple_shot_count: int = 0  # Cuántas veces se ha obtenido
var speed_boost_count: int = 0  # Cuántas veces se ha obtenido el boost
var has_regeneration: bool = false
var regen_timer: float = 0.0
var time_since_last_damage: float = 0.0
const REGEN_DELAY: float = 9.0  # Segundos sin daño antes de regenerar
const REGEN_AMOUNT: int = 2

# Referencia al sistema de mejoras
var upgrade_cards: Node = null

func _ready():
	current_health = max_health
	is_dead = false
	can_take_damage = true
	is_dead = false
	can_take_damage = true
	survival_time = 0.0
	kill_count = 0
	current_xp = 0
	current_level = 1
	time_since_last_damage = 0.0
	
	set_physics_process(true)
	set_process(true)
	
	animated_sprite.play("idle")
	
	if not is_in_group("player"):
		add_to_group("player")
	
	create_health_bar()
	
	# Buscar el HUD después de que todos los nodos estén listos
	call_deferred("find_hud")
	call_deferred("find_upgrade_cards")

func find_hud():
	hud = get_tree().get_first_node_in_group("hud")
	if hud:
		print("✅ HUD encontrado!")
		if hud.has_method("update_health"):
			hud.update_health(current_health, max_health)
		if hud.has_method("update_xp_bar"):
			var threshold = xp_thresholds[min(current_level - 1, xp_thresholds.size() - 1)]
			hud.update_xp_bar(current_xp, threshold, current_level)
	else:
		print("❌ ERROR: HUD no encontrado en el grupo 'hud'")

func find_upgrade_cards():
	upgrade_cards = get_tree().get_first_node_in_group("upgrade_cards")
	if upgrade_cards:
		print("✅ UpgradeCards encontrado!")
		if not upgrade_cards.upgrade_selected.is_connected(_on_upgrade_selected):
			upgrade_cards.upgrade_selected.connect(_on_upgrade_selected)
	else:
		print("⚠️ UpgradeCards no encontrado, se buscará más tarde")

func _process(delta):
	if not is_dead:
		survival_time += delta
		time_since_last_damage += delta
		
		# Sistema de regeneración
		if has_regeneration and time_since_last_damage >= REGEN_DELAY:
			regen_timer += delta
			if regen_timer >= 1.0:  # Regenerar cada segundo después del delay
				regen_timer = 0.0
				heal(REGEN_AMOUNT)
		
		# Actualizar el timer en el HUD
		if hud and hud.has_method("update_time"):
			hud.update_time(survival_time)

func _physics_process(_delta):
	if is_dead:
		return
		
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		last_direction = input_vector
	
	velocity = input_vector * speed
	
	if velocity.length() > 0:
		animated_sprite.play("run")
		if velocity.x > 0:
			animated_sprite.flip_h = false
		elif velocity.x < 0:
			animated_sprite.flip_h = true
	else:
		if animated_sprite.animation != "receivedamage":
			animated_sprite.play("idle")
	
	move_and_slide()

func _on_fire_timer_timeout():
	if bullet_scene == null or is_dead:
		return
	
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	
	# Disparo principal
	shoot_bullet(shoot_direction)
	
	# Disparos adicionales si tiene triple shot
	if has_triple_shot:
		# Disparar proyectiles adicionales con un pequeño delay
		for i in range(triple_shot_count):
			await get_tree().create_timer(0.08 * (i + 1)).timeout
			if is_dead:
				return
			# Recalcular dirección hacia el mouse
			var new_mouse_pos = get_global_mouse_position()
			var new_direction = (new_mouse_pos - global_position).normalized()
			shoot_bullet(new_direction)

func shoot_bullet(direction: Vector2):
	if bullet_scene == null:
		return
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.set_direction(direction)

func take_damage(amount: int):
	if not can_take_damage or is_dead:
		return
	
	# Reset del timer de regeneración
	time_since_last_damage = 0.0
	regen_timer = 0.0
		
	current_health -= amount
	current_health = max(0, current_health)
	
	if health_bar:
		health_bar.update_health(current_health, max_health)
	
	# Actualizar el HUD
	if hud and hud.has_method("update_health"):
		hud.update_health(current_health, max_health)
	
	print("Player HP: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()
	else:
		can_take_damage = false
		if has_node("TimerIFrames"):
			$TimerIFrames.start()
		else:
			var timer = get_tree().create_timer(1.0)
			timer.timeout.connect(func(): can_take_damage = true)
		
		if animated_sprite.sprite_frames.has_animation("receivedamage"):
			animated_sprite.play("receivedamage")

func heal(amount: int):
	if is_dead:
		return
	
	var old_health = current_health
	current_health = min(current_health + amount, max_health)
	
	if current_health > old_health:
		print("💚 Regenerado: +", current_health - old_health, " HP")
		
		if health_bar:
			health_bar.update_health(current_health, max_health)
		
		if hud and hud.has_method("update_health"):
			hud.update_health(current_health, max_health)

func _on_hurtbox_body_entered(body):
	if body.is_in_group("enemy") and not is_dead:
		take_damage(body.damage)

func _on_timer_i_frames_timeout():
	can_take_damage = true

func die():
	if is_dead:
		return
	
	is_dead = true
	print("Player died! Showing Game Over...")
	
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	if animated_sprite.sprite_frames.has_animation("die"):
		animated_sprite.play("die")
		await animated_sprite.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	show_game_over()

func show_game_over():
	print("Calling show_game_over()...")
	
	if game_over_scene == null:
		print("ERROR: game_over_scene not assigned in inspector!")
		print("Trying to load GameOver.tscn manually...")
		game_over_scene = load("res://scenes/ui/GameOver.tscn")
		if game_over_scene == null:
			print("ERROR: Could not load GameOver.tscn")
			return
	
	var game_over = game_over_scene.instantiate()
	
	print("Adding Game Over to scene tree...")
	get_tree().root.add_child(game_over)
	
	await get_tree().process_frame
	
	if game_over.has_method("set_stats"):
		game_over.set_stats(survival_time, kill_count)
		print("Stats sent: Time=", survival_time, ", Kills=", kill_count)
	
	print("Game Over added successfully!")

func add_kill():
	kill_count += 1
	print("Kills: ", kill_count)
	# Actualizar el HUD
	if hud and hud.has_method("update_kills"):
		hud.update_kills(kill_count)

func gain_xp(amount: int):
	current_xp += amount
	print("XP Gained: ", amount, " | Total: ", current_xp)
	
	# Obtener el umbral actual para subir de nivel
	var level_index = current_level - 1
	if level_index < xp_thresholds.size():
		var threshold = xp_thresholds[level_index]
		
		# Actualizar barra de XP en el HUD
		if hud and hud.has_method("update_xp_bar"):
			hud.update_xp_bar(current_xp, threshold, current_level)
		
		# Verificar si subió de nivel
		if current_xp >= threshold:
			level_up()
	else:
		# Ya está en el nivel máximo
		if hud and hud.has_method("update_xp"):
			hud.update_xp(current_xp)

func level_up():
	current_level += 1
	print("🎉 ¡SUBISTE AL NIVEL ", current_level, "!")
	
	# Mostrar pantalla de selección de mejoras
	if upgrade_cards == null:
		find_upgrade_cards()
	
	if upgrade_cards and upgrade_cards.has_method("show_upgrade_selection"):
		upgrade_cards.show_upgrade_selection()
	else:
		print("⚠️ No se pudo mostrar el menú de mejoras")
	
	# Actualizar HUD con el nuevo nivel
	if hud and hud.has_method("update_level"):
		hud.update_level(current_level)

func _on_upgrade_selected(upgrade_type: String):
	print("Aplicando mejora: ", upgrade_type)
	
	match upgrade_type:
		"triple_shot":
			has_triple_shot = true
			triple_shot_count += 1  # Cada vez que se obtiene, añade 1 disparo más
			print("🔥 Disparo Triple activado! Disparos adicionales: ", triple_shot_count)
		
		"speed_boost":
			speed_boost_count += 1
			speed *= 1.04  # +4% de velocidad
			print("⚡ Velocidad aumentada a: ", speed)
		
		"regeneration":
			has_regeneration = true
			print("💚 Regeneración activada!")
	
	# Actualizar la barra de XP para el siguiente nivel
	var level_index = current_level - 1
	if level_index < xp_thresholds.size():
		var threshold = xp_thresholds[level_index]
		if hud and hud.has_method("update_xp_bar"):
			hud.update_xp_bar(current_xp, threshold, current_level)

func create_health_bar():
	var health_bar_script = load("res://scenes/player/simple_health_bar.gd")
	if health_bar_script:
		health_bar = Node2D.new()
		health_bar.set_script(health_bar_script)
		health_bar.max_health = max_health
		add_child(health_bar)
		health_bar.update_health(current_health, max_health)
