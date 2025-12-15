# game_over.gd

extends CanvasLayer

var survival_time_label: Label
var kills_label: Label
var retry_button: Button
var quit_button: Button
var animation_player: AnimationPlayer

var survival_time: float = 0.0
var total_kills: int = 0

func _ready():
	get_tree().paused = true
	
	survival_time_label = $Panel/VBoxContainer/StatsContainer/SurvivalTimeLabel
	kills_label = $Panel/VBoxContainer/StatsContainer/KillsLabel
	retry_button = $Panel/VBoxContainer/ButtonsContainer/RetryButton
	quit_button = $Panel/VBoxContainer/ButtonsContainer/QuitButton
	animation_player = $AnimationPlayer
	
	update_stats()
	
	retry_button.pressed.connect(_on_retry_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
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
	print("Retry button pressed!")
	get_tree().paused = false
	var scene_path = get_tree().current_scene.scene_file_path
	queue_free()
	get_tree().change_scene_to_file(scene_path)
	get_tree().reload_current_scene()

func _on_quit_pressed():
	print("Quit button pressed!")
	get_tree().paused = false
	get_tree().quit()
