extends Node

@export var show_speed : float = 0.05  # 每個字元顯示的秒數

@onready var dialog = get_node("/root/Game/Gui/Dialog")
@onready var text_label = dialog.get_node("HBoxContainer/Label")
var show_text_tween : Tween

func _ready() -> void:
	dialog.hide()

func show_text(text: String):
	dialog.show()
	
	text_label.text = text
	text_label.visible_ratio = 0
	
	if show_text_tween:
		show_text_tween.kill()
	
	show_text_tween = create_tween()
	show_text_tween.tween_property(text_label, "visible_ratio", 1.0, show_speed * len(text))
