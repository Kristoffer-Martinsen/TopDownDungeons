extends Node2D
class_name GameHandler

var character_scene = preload("res://Scenes/Actor/Player/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_dungeon_character_spawn(Vector2(50, 50))

func _on_dungeon_character_spawn(spawn_location: Vector2):
	var character = character_scene.instantiate()
	add_child.call_deferred(character)
	character.position = spawn_location
