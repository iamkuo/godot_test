extends Node

@export var show_speed : float = 0.02  # 每個字元顯示的秒數
@onready var dialog = get_node("/root/Game/Gui/Dialog")
@onready var text_start = dialog.get_node("HBoxContainer/Start")
@onready var text_label = dialog.get_node("HBoxContainer/Label")
@onready var text_end = dialog.get_node("HBoxContainer/End")
var show_text_tween : Tween
enum dialog_state {
	READY,
	READING,
	FINISHED
}

var current_state = dialog_state.READY
var text_queue = []

func _ready() -> void:
	hide_text()
	
func _process(delta: float) -> void:
	match current_state:
		dialog_state.READY:
			if !text_queue.is_empty(): show_text()
		dialog_state.READING:
			if Input.is_action_just_pressed("ui_accept"):
				show_text_tween.finished.emit()
				show_text_tween.kill()
				text_label.visible_ratio = 1
		dialog_state.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				if !text_queue.is_empty():
					show_text()
				else:
					hide_text()
					dialog_change_state(dialog_state.READY)

func queue_text(next_text:String):
	text_queue.push_back(next_text)
	
func hide_text():
	text_label.text = ""
	text_end.text = ""
	dialog.hide()

func show_text():
	dialog_change_state(dialog_state.READING)
	var next_text = text_queue.pop_front()
	text_label.text = next_text
	text_end.text = ""
	text_label.visible_ratio = 0
	dialog.show()
	if show_text_tween: show_text_tween.kill()
	show_text_tween = create_tween()
	show_text_tween.tween_property(text_label, "visible_ratio", 1.0, show_speed * len(next_text))
	await show_text_tween.finished
	text_end.text = "v"
	dialog_change_state(dialog_state.FINISHED)

func dialog_change_state(next_state):
	current_state = next_state
	match current_state:
		dialog_state.READY:
			print("state change to ready")
		dialog_state.READING:
			print("state change to reading")
		dialog_state.FINISHED:
			print("state change to finished")	
