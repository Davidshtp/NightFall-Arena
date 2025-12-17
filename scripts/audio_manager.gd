# scripts/audio_manager.gd - VERSIÓN ULTRA SIMPLIFICADA
extends Node

# Permite asignar una canción externa desde el Inspector (ej: .mp3 u .ogg)
@export var music_stream: AudioStream

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = -7 # Volumen ajustado a ~45%
	add_child(music_player)
	
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
