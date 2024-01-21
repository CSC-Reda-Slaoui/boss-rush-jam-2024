extends Node2D

var music_player
@export var state = ""

func _ready():
	music_player = AudioStreamPlayer2D.new()
	add_child(music_player)

func main():
	state = "main"
	var tween = get_tree().create_tween()
	music_player.volume_db = -100
	music_player.stream = load("res://music/mainmenu.wav")
	music_player.play()
	tween.tween_property(music_player, "volume_db", 0, 2)

func pyroclast():
	state = "pyroclast"
	var tween = get_tree().create_tween()
	music_player.volume_db = -100
	music_player.stream = load("res://music/pyroclast.wav")
	music_player.play()
	tween.tween_property(music_player, "volume_db", 0, 1)

func shadowstalker():
	state = "shadowstalker"
	var tween = get_tree().create_tween()
	music_player.volume_db = -100
	music_player.stream = load("res://music/shadowstalker.wav")
	music_player.play()
	tween.tween_property(music_player, "volume_db", 0, 1)

func stop():
	state = "none"
	var tween = get_tree().create_tween()
	tween.tween_property(music_player, "volume_db", -100, 3)
