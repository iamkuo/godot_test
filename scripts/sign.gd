extends Node2D

@export_multiline var sign_texts : Array[String]

var player_in_range : bool = false

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		if GuiManager.current_state == GuiManager.dialog_state.READY:
			show_sign_texts()

func _on_body_entered(body: Node2D) -> void:
	player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	player_in_range = false

func show_sign_texts() -> void:
	for text in sign_texts:
		GuiManager.queue_text(text)
