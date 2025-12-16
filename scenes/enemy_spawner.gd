# enemy_spawner.gd

extends Node2D

# 🎯 Escenas de Enemigos que vamos a instanciar (Arrastrar desde el Inspector)
@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_radius: float = 800.0 # Distancia para generar enemigos lejos del Player

# 🌊 Sistema de Oleadas
@export var base_enemies_per_wave: int = 5 # Enemigos base por oleada
@export var enemies_increase_per_wave: int = 3 # Incremento de enemigos por oleada
@export var wave_pause_duration: float = 3.0 # Pausa entre oleadas en segundos
@export var spawn_interval: float = 0.8 # Intervalo entre spawns de enemigos en la misma oleada

var player: Node2D
var spawn_timer: Timer
var wave_pause_timer: Timer
var wave_notification_label: Label

# Variables de control de oleadas
var current_wave: int = 0
var enemies_per_wave: int = 0
var enemies_spawned_this_wave: int = 0
var enemies_alive: int = 0
var is_spawning_wave: bool = false
var is_paused_between_waves: bool = false

func _ready():
	# Buscamos al Player (asumiendo que está en el grupo "player")
	player = get_tree().get_first_node_in_group("player")
	
	# Obtener referencias a los timers
	spawn_timer = $SpawnTimer
	if spawn_timer:
		spawn_timer.wait_time = spawn_interval
		spawn_timer.autostart = false
	
	# Crear timer para pausa entre oleadas
	wave_pause_timer = Timer.new()
	wave_pause_timer.wait_time = wave_pause_duration
	wave_pause_timer.one_shot = true
	wave_pause_timer.timeout.connect(_on_wave_pause_timeout)
	add_child(wave_pause_timer)
	
	# Crear label para notificación de oleada
	create_wave_notification()
	
	# Iniciar verificación periódica de enemigos vivos
	check_enemies_timer()
	
	# Iniciar primera oleada después de un breve delay
	await get_tree().create_timer(1.0).timeout
	start_next_wave()

func check_enemies_timer():
	# Verificar enemigos vivos periódicamente
	var check_timer = Timer.new()
	check_timer.wait_time = 0.5 # Verificar cada 0.5 segundos
	check_timer.timeout.connect(_check_enemies_alive)
	check_timer.autostart = true
	add_child(check_timer)

var last_enemy_count: int = 0

func _check_enemies_alive():
	# Actualizar contador de enemigos vivos siempre
	var current_count = get_alive_enemies_count()
	
	# Si el número de enemigos cambió, actualizar contador
	if current_count != last_enemy_count:
		enemies_alive = current_count
		last_enemy_count = current_count
		
		# Solo verificar si la oleada está completa cuando no estamos spawnando
		if not is_spawning_wave and not is_paused_between_waves:
			# Si todos los enemigos murieron y ya se spawnearon todos
			if enemies_alive <= 0 and enemies_spawned_this_wave >= enemies_per_wave and current_wave > 0:
				print("🎉 Oleada %d completada!" % current_wave)
				start_wave_pause()

func create_wave_notification():
	# Crear un CanvasLayer para la notificación
	var notification_layer = CanvasLayer.new()
	notification_layer.name = "WaveNotification"
	notification_layer.layer = 100 # Asegurar que esté por encima de todo
	get_tree().root.add_child(notification_layer)
	
	# Crear label centrado usando Control
	var center_container = Control.new()
	center_container.name = "CenterContainer"
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	notification_layer.add_child(center_container)
	
	wave_notification_label = Label.new()
	wave_notification_label.name = "WaveLabel"
	wave_notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wave_notification_label.add_theme_font_size_override("font_size", 72)
	wave_notification_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2, 1))
	wave_notification_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	wave_notification_label.add_theme_constant_override("shadow_offset_x", 4)
	wave_notification_label.add_theme_constant_override("shadow_offset_y", 4)
	wave_notification_label.visible = false
	
	# Centrar el label usando anchors
	wave_notification_label.set_anchors_preset(Control.PRESET_CENTER)
	wave_notification_label.offset_left = -200
	wave_notification_label.offset_top = -50
	wave_notification_label.offset_right = 200
	wave_notification_label.offset_bottom = 50
	
	center_container.add_child(wave_notification_label)

func start_next_wave():
	if is_paused_between_waves:
		return
	
	current_wave += 1
	enemies_per_wave = base_enemies_per_wave + (current_wave - 1) * enemies_increase_per_wave
	enemies_spawned_this_wave = 0
	enemies_alive = 0
	is_spawning_wave = true
	
	print("🌊 Iniciando OLEADA %d con %d enemigos" % [current_wave, enemies_per_wave])
	
	# Mostrar notificación de oleada
	show_wave_notification()
	
	# Iniciar spawn de enemigos
	if spawn_timer:
		spawn_timer.start()

func show_wave_notification():
	if not wave_notification_label:
		return
	
	wave_notification_label.text = "OLEADA %d" % current_wave
	wave_notification_label.visible = true
	wave_notification_label.modulate.a = 1.0
	
	# Guardar posición inicial
	var initial_y = wave_notification_label.offset_top
	
	# Animación de fade in/out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave_notification_label, "modulate:a", 0.0, 1.5).set_delay(1.0)
	tween.tween_property(wave_notification_label, "offset_top", initial_y - 50, 1.5).set_delay(1.0)
	
	await tween.finished
	wave_notification_label.visible = false
	wave_notification_label.offset_top = initial_y # Resetear posición

func _on_spawn_timer_timeout():
	if player == null or enemy_scenes.is_empty():
		return
	
	if not is_spawning_wave or is_paused_between_waves:
		return
	
	# Verificar si ya spawnearon todos los enemigos de esta oleada
	if enemies_spawned_this_wave >= enemies_per_wave:
		spawn_timer.stop()
		is_spawning_wave = false
		print("✅ Todos los enemigos de la oleada %d han sido spawnados" % current_wave)
		return
	
	# Spawnear un enemigo
	spawn_enemy()

func spawn_enemy():
	# 1. Seleccionar Enemigo al azar
	var enemy_scene = enemy_scenes.pick_random()
	
	# 2. Determinar la posición de aparición fuera de la vista
	var spawn_position = get_random_spawn_position()
	
	# 3. Instanciar y añadir
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_position
	
	# 4. Añadir al grupo de enemigos si no está
	if not enemy.is_in_group("enemy"):
		enemy.add_to_group("enemy")
	
	# 5. Incrementar contadores
	enemies_spawned_this_wave += 1
	
	# Actualizar contador de enemigos vivos desde el grupo
	enemies_alive = get_alive_enemies_count()
	last_enemy_count = enemies_alive
	
	print("👾 Enemigo spawnado (%d/%d de la oleada %d) - Enemigos vivos: %d" % [enemies_spawned_this_wave, enemies_per_wave, current_wave, enemies_alive])

func start_wave_pause():
	is_paused_between_waves = true
	wave_pause_timer.start()
	print("⏸️ Pausa entre oleadas iniciada (%d segundos)" % wave_pause_duration)

func _on_wave_pause_timeout():
	is_paused_between_waves = false
	print("▶️ Pausa terminada, iniciando siguiente oleada...")
	start_next_wave()

func get_random_spawn_position() -> Vector2:
	var angle = randf() * TAU # Ángulo aleatorio (0 a 360 grados)
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	
	return player.global_position + offset

# Función auxiliar para obtener enemigos vivos (por si acaso)
func get_alive_enemies_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()
