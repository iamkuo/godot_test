extends Control
@onready var main = $"../../../../.."





func _on_continue_pressed():
	main.pause()


func _on_exit_pressed():
	get_tree().quit()
