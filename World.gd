extends Node2D

func _ready():
	_spawn_player()

func _spawn_player() -> void:
	$Player.position = $PSpawn.position
