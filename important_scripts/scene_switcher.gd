extends Node

var current_scene = null
@onready var scene_container = get_node("/root/Game/SceneContainer")
@onready var animation_player = get_node("/root/Game/GUI/FullscreenUI/AnimationPlayer")
@onready var transition_rect = get_node("/root/Game/GUI/FullscreenUI/TransitionRect")

func _ready() -> void: 
	await get_tree().process_frame
	if scene_container.get_child_count() > 0:
		current_scene = scene_container.get_child(0)

func switch_scene(name: String, transition_type: String):
	call_deferred("_deferred_switch_scene", name, transition_type)

func _deferred_switch_scene(name: String, transition_type: String):
	transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	animation_player.play("%s_in" % transition_type)
	await animation_player.animation_finished
	current_scene.queue_free()
	var new_scene = load("res://scenes/%s.tscn" % name)
	current_scene = new_scene.instantiate()
	scene_container.add_child(current_scene)  # 添加到固定容器
	animation_player.play("%s_out" % transition_type)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
