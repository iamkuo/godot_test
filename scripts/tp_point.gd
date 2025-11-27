extends Area2D

func _init() -> void:
	pass
	#print("hehe boi")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("player detected")
	SceneManager.switch_scene("test_area","fade")
