# game_over.gd

extends CanvasLayer

var survival_time_label: Label
var kills_label: Label
var retry_button: Button
var quit_button: Button
var animation_player: AnimationPlayer

var survival_time: float = 0.0
var total_kills: int = 0

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("🖱️ CLIC DETECTADO en Game Over!")
		print("  Posición: ", event.position)
		
		# Verificar si el clic está sobre el botón Retry
		if retry_button and retry_button.get_global_rect().has_point(event.position):
			print("  ✅ Clic en RETRY BUTTON!")
			_on_retry_pressed()
			get_viewport().set_input_as_handled()
		# Verificar si el clic está sobre el botón Quit
		elif quit_button and quit_button.get_global_rect().has_point(event.position):
			print("  ✅ Clic en QUIT BUTTON!")
			_on_quit_pressed()
			get_viewport().set_input_as_handled()

func _ready():
	print("🎮 GameOver _ready() iniciado")
	get_tree().paused = true
	
	survival_time_label = $Panel/VBoxContainer/StatsContainer/SurvivalTimeLabel
	kills_label = $Panel/VBoxContainer/StatsContainer/KillsLabel
	retry_button = $Panel/VBoxContainer/ButtonsContainer/RetryButton
	quit_button = $Panel/VBoxContainer/ButtonsContainer/QuitButton
	animation_player = $AnimationPlayer
	
	print("📊 Nodos encontrados:")
	print("  - survival_time_label: ", survival_time_label != null)
	print("  - kills_label: ", kills_label != null)
	print("  - retry_button: ", retry_button != null)
	print("  - quit_button: ", quit_button != null)
	
	update_stats()
	
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
		print("✅ Retry button conectado")
	else:
		print("❌ ERROR: retry_button es null")
	
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		print("✅ Quit button conectado")
	else:
		print("❌ ERROR: quit_button es null")
	
	if animation_player:
		animation_player.play("fade_in")

func set_stats(time: float, kills: int):
	survival_time = time
	total_kills = kills
	if is_node_ready():
		update_stats()

func update_stats():
	if not survival_time_label or not kills_label:
		return
	
	var time_int = int(survival_time)
	var minutes = time_int / 60
	var seconds = time_int % 60
	survival_time_label.text = "Tiempo sobrevivido: %d:%02d" % [minutes, seconds]
	kills_label.text = "Enemigos eliminados: %d" % total_kills

func _on_retry_pressed():
	print("🔄 RETRY BUTTON CLICKED!")
	print("  1. Despausando juego...")
	get_tree().paused = false
	print("  2. Eliminando Game Over...")
	queue_free()
	print("  3. Recargando escena...")
	get_tree().reload_current_scene()
	print("  4. Escena recargada!")

func _on_quit_pressed():
	print("🚪 QUIT BUTTON CLICKED!")
	print("  1. Despausando juego...")
	get_tree().paused = false
	print("  2. Cerrando juego...")
	get_tree().quit()
	print("  3. Juego cerrado!")
