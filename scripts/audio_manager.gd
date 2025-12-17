# scripts/audio_manager.gd - VERSIÓN ULTRA SIMPLIFICADA
extends Node

# Permite asignar una canción externa desde el Inspector (ej: .mp3 u .ogg)
@export var music_stream: AudioStream

# SFX
@export var hit_sound: AudioStream
@export var game_over_sound: AudioStream
@export var game_over_voice: AudioStream

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var sfx_player2: AudioStreamPlayer  # Para reproducir voz + sonido simultaneamente

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = -7 # Volumen ajustado a ~45%
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	sfx_player.volume_db = -5
	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS  # No se pausa
	add_child(sfx_player)
	
	sfx_player2 = AudioStreamPlayer.new()
	sfx_player2.bus = "Master"
	sfx_player2.volume_db = -3
	sfx_player2.process_mode = Node.PROCESS_MODE_ALWAYS  # No se pausa
	add_child(sfx_player2)
	
	# Añadir al grupo para acceso global
	if not is_in_group("audio_manager"):
		add_to_group("audio_manager")

func start_battle_music():
	if music_player.playing:
		return
	
	if music_stream:
		music_player.stream = music_stream
		music_player.play()

func stop_music():
	music_player.stop()

func play_hit():
	if hit_sound:
		sfx_player.stream = hit_sound
		sfx_player.play()

func play_game_over():
	# Reproducir sonido y voz simultáneamente
	if game_over_sound:
		sfx_player.stream = game_over_sound
		sfx_player.play()
	if game_over_voice:
		sfx_player2.stream = game_over_voice
		sfx_player2.play()
