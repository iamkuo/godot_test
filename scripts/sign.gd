extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	GuiManager.show_text("never gonna give you up")
