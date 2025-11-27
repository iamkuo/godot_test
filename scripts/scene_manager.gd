extends Node

var current_scene = null
var animation_player: AnimationPlayer
var transition_rect: ColorRect

func _ready() -> void:
	animation_player = get_tree().root.get_node_or_null("Game/SceneChange/AnimationPlayer")
	transition_rect = get_tree().root.get_node_or_null("Game/SceneChange/TransitionRect")
	var game = get_tree().root.get_child(1)
	current_scene = game.get_child(game.get_child_count()-1)

func switch_scene(name: String, transition_type: String):
	print("switching scene")
	call_deferred("_deferred_switch_scene", name, transition_type)

func _deferred_switch_scene(name: String, transition_type: String):
	transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	animation_player.play("%s_in" % transition_type)
	await animation_player.animation_finished
	current_scene.free()
	var new_scene = load("res://scenes/%s.tscn" % name)
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	animation_player.play("%s_out" % transition_type)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	print("scene switched")
