extends Node

# =============================
# Constants and Exports
# =============================
@export var show_speed: float = 0.02  # 每個字元顯示的秒數

# =============================
# Dialog UI References
# =============================
@onready var dialog: Control = get_node("/root/Game/GUI/Dialog") as Control
@onready var text_label: Label = dialog.get_node("HBoxContainer/Label") as Label if dialog else null
@onready var text_end: Label = dialog.get_node("HBoxContainer/End") as Label if dialog else null

# =============================
# Fullscreen UI References
# =============================
@onready var fullscreen_ui: Control = get_node("/root/Game/GUI/FullscreenUI") as Control
@onready var color_rect: ColorRect = fullscreen_ui.get_node("ColorRect") as ColorRect if fullscreen_ui else null
@onready var fullscreen_label: Label = fullscreen_ui.get_node("Label") as Label if fullscreen_ui else null
@onready var texture_rect: TextureRect = fullscreen_ui.get_node("TextureRect") as TextureRect if fullscreen_ui else null

# =============================
# State Variables
# =============================
var dialog_tween: Tween = null
var fullscreen_tween: Tween = null
var current_state = output_state.READY
var text_queue: Array[String] = []
var fullscreen_queue: Array[Dictionary] = []
var fullscreen_active: bool = false
var fullscreen_state = output_state.READY

# =============================
# Enums
# =============================
enum output_state {
	READY,
	READING,
	FINISHED
}

# =============================
# Signals
# =============================
signal dialog_finished()
signal fullscreen_finished()

func _ready() -> void:
	_hide_text()
	_hide_fullscreen()
	
func _process(_delta: float) -> void:
	# Process fullscreen state
	match fullscreen_state:
		output_state.READY:
			if !fullscreen_queue.is_empty(): _show_fullscreen_item()
		output_state.READING:
			if Input.is_action_just_pressed("ui_accept"):
				if fullscreen_tween:
					fullscreen_tween.kill()
					fullscreen_tween = null
				if fullscreen_queue[0].has("text"):
					fullscreen_label.visible_ratio = 1.0
					_hide_fullscreen()
					_fullscreen_change_state(output_state.FINISHED)
				else:
					_fullscreen_change_state(output_state.READY)
		
		output_state.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				if !fullscreen_queue.is_empty():
					_show_fullscreen_item()
				else:
					_hide_fullscreen()
					emit_signal("fullscreen_finished")
					_fullscreen_change_state(output_state.READY)
	
	if fullscreen_active: return
	
	# Process dialog state
	match current_state:
		output_state.READY:
			if !text_queue.is_empty(): _show_text()
		output_state.READING:
			if Input.is_action_just_pressed("ui_accept"):
				if dialog_tween:
					dialog_tween.kill()
					dialog_tween = null
				text_label.visible_ratio = 1.0
				text_end.text = "v"
				_dialog_change_state(output_state.FINISHED)
		
		output_state.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				if !text_queue.is_empty():
					_show_text()
				else:
					_hide_text()
					emit_signal("dialog_finished")
					_dialog_change_state(output_state.READY)

# =============================
# Dialog Functions
# =============================
func queue_text(next_text: String) -> void:
	text_queue.push_back(next_text)
	
func queue_texts(texts: Array[String]) -> void:
	for t in texts:
		text_queue.push_back(t)

func _hide_text() -> void:
	text_label.text = ""
	text_end.text = ""
	dialog.hide()

func _show_text() -> void:
	_dialog_change_state(output_state.READING)
	var next_text = text_queue.pop_front()
	text_label.text = next_text
	text_end.text = ""
	text_label.visible_ratio = 0
	dialog.show()
	
	# Clean up previous tween if exists
	if dialog_tween and dialog_tween.is_running():
		dialog_tween.kill()
		dialog_tween = null
	
	# Create new tween
	dialog_tween = create_tween()
	dialog_tween.tween_property(text_label,
								"visible_ratio",
								1.0,
								show_speed * len(next_text))
	
	await dialog_tween.finished
	text_end.text = "v"
	_dialog_change_state(output_state.FINISHED)

func _dialog_change_state(next_state: int) -> void:
	var previous_state = current_state
	current_state = next_state as output_state
	
	match current_state:
		output_state.READY:
			print("Dialog state: READY")
		output_state.READING:
			print("Dialog state: READING")
		output_state.FINISHED:
			print("Dialog state: FINISHED")
			
	print("Dialog state changed from %s to %s" % [output_state.keys()[previous_state],
	output_state.keys()[current_state]])



# =============================
# Fullscreen UI Functions
# =============================
func queue_fullscreen_text(text: String) -> void:
	fullscreen_queue.push_back({"type": "text", "text": text})

func queue_fullscreen_image(texture: Texture2D) -> void:
	fullscreen_queue.push_back({"type": "image", "texture": texture})

func _show_fullscreen_item() -> void:
	if fullscreen_queue.is_empty():
		return
	
	var item = fullscreen_queue[0]
	_fullscreen_change_state(output_state.READING)
	
	if item.type == "text":
		var text = item.text
		fullscreen_label.text = text
		fullscreen_label.visible_ratio = 0
		texture_rect.hide()
		fullscreen_label.show()
		color_rect.show()
		fullscreen_ui.show()
		fullscreen_active = true
		# Clean up previous tween if exists
		if fullscreen_tween and fullscreen_tween.is_running():
			fullscreen_tween.kill()
			fullscreen_tween = null
		# Create new tween for text reveal
		fullscreen_tween = create_tween()
		fullscreen_tween.tween_property(fullscreen_label,
								"visible_ratio",
								1.0,
								show_speed * len(text))
		await fullscreen_tween.finished
		_fullscreen_change_state(output_state.FINISHED)
	elif item.type == "image":
		var texture = item.texture
		texture_rect.texture = texture
		fullscreen_label.hide()
		texture_rect.show()
		color_rect.show()
		fullscreen_ui.show()
		fullscreen_active = true
		_fullscreen_change_state(output_state.FINISHED)

func _hide_fullscreen() -> void:
	# Clean up tweens first
	if fullscreen_tween:
		fullscreen_tween.kill()
		fullscreen_tween = null

	# Hide all UI elements
	fullscreen_ui.hide()
	color_rect.hide()
	fullscreen_label.hide()
	texture_rect.hide()
	
	fullscreen_active = false
	
	# Clean up texture to free memory
	texture_rect.texture = null
	
	if !fullscreen_queue.is_empty():
		fullscreen_queue.pop_front()

func _fullscreen_change_state(next_state: int) -> void:
	var previous_state = fullscreen_state
	fullscreen_state = next_state as output_state
	match fullscreen_state:
		output_state.READY:
			print("Fullscreen state: READY")
		output_state.READING:
			print("Fullscreen state: READING")
		output_state.FINISHED:
			print("Fullscreen state: FINISHED")
	
	print("Fullscreen state changed from %s to %s" % [output_state.keys()[previous_state],
	output_state.keys()[fullscreen_state]])
