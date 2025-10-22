extends Node

var current_scene = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)

func switch_scene(name: String):
	print("switching scene")
	call_deferred("_deferred_switch_scene",name)

func _deferred_switch_scene(name: String):
	current_scene.free()
	current_scene = load("res://scenes/%s.tscn" %name)
	current_scene = current_scene.instantiate()
	get_tree().root.add_child(current_scene)
	print("scene switched")
