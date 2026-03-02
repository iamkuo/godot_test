extends Control
@onready var main = $"../../../../.."
func _ready():
	$".".visible = false

	




func _on_continue_pressed():
	main.pause()


func _on_exit_pressed():
	get_tree().quit()




func _on_pausebutton_pressed():
	$".".visible = true
