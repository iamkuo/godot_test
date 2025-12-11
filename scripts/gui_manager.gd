extends CanvasLayer
@export var show_speed : int
@onready var dialog = $Dialog
@onready var text_label = $Dialog/HBoxContainer/Label
@onready var show_text_tween = create_tween()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialog.hide()

func show_text(text:String):
	text_label.text = text
	text_label.visible_ratio = 0
	show_text_tween.tween_property(text_label,"visible_ratio",1,show_speed*len(text),)
	show_text_tween.play()
