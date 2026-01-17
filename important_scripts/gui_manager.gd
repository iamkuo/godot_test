extends Node

# =============================
# Constants and Exports
# =============================
@export var show_speed: float = 0.02  # 每個字元顯示的秒數

# =============================
# Dialog UI References
# =============================
@onready var dialog: Control = get_node_or_null("/root/Game/Gui/Dialog") as Control
@onready var text_label: Label = dialog.get_node("HBoxContainer/Label") as Label if dialog else null
@onready var text_end: Label = dialog.get_node("HBoxContainer/End") as Label if dialog else null

# =============================
# Fullscreen UI References
# =============================
@onready var fullscreen_ui: Control = get_node_or_null("/root/Game/Gui/FullscreenUI") as Control
@onready var color_rect: ColorRect = fullscreen_ui.get_node("ColorRect") as ColorRect if fullscreen_ui else null
@onready var fullscreen_label: Label = fullscreen_ui.get_node("Label") as Label if fullscreen_ui else null
@onready var texture_rect: TextureRect = fullscreen_ui.get_node("TextureRect") as TextureRect if fullscreen_ui else null

# =============================
# State Variables
# =============================
var show_text_tween: Tween = null
var current_state = dialog_state.READY
var text_queue: Array[String] = []
var fullscreen_active: bool = false

# =============================
# Enums
# =============================
enum dialog_state {
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
	
func _process(_delta: float) -> void:
	# Process fullscreen UI input
	if fullscreen_active:
		if Input.is_action_just_pressed("ui_accept"):
			_hide_fullscreen()
		return
	
	# Process dialog state
	match current_state:
		dialog_state.READY:
			if !text_queue.is_empty(): _show_text()
		dialog_state.READING:
			if Input.is_action_just_pressed("ui_accept") and show_text_tween:
				if show_text_tween and show_text_tween.is_running():
					show_text_tween.kill()
				if text_label:
					text_label.visible_ratio = 1.0
		
		dialog_state.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				if !text_queue.is_empty():
					_show_text()
				else:
					_hide_text()
					_dialog_change_state(dialog_state.READY)

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
	_dialog_change_state(dialog_state.READING)
	var next_text = text_queue.pop_front()
	text_label.text = next_text
	text_end.text = ""
	text_label.visible_ratio = 0
	dialog.show()
	
	# Clean up previous tween if exists
	if show_text_tween and show_text_tween.is_running():
		show_text_tween.kill()
	
	# Create new tween
	show_text_tween = create_tween()
	show_text_tween.tween_property(text_label, "visible_ratio", 1.0, show_speed * len(next_text))
	
	await show_text_tween.finished
	text_end.text = "v"
	_dialog_change_state(dialog_state.FINISHED)

func _dialog_change_state(next_state: int) -> void:
	var previous_state = current_state
	current_state = next_state as dialog_state  # Cast the integer to dialog_state enum
	
	match current_state:
		dialog_state.READY:
			print("Dialog state: READY")
		dialog_state.READING:
			print("Dialog state: READING")
		dialog_state.FINISHED:
			emit_signal("dialog_finished")
			print("Dialog state: FINISHED")
			
	print("Dialog state changed from %s to %s" % [dialog_state.keys()[previous_state], dialog_state.keys()[current_state]])

# =============================
# Fullscreen UI Functions
# =============================
func show_fullscreen_text(text: String, wait_for_input: bool = true, display_time: float = 2.0) -> void:
	# Set up the text and UI elements
	fullscreen_label.text = text
	fullscreen_label.visible_ratio = 0  # Start with text hidden
	texture_rect.hide()
	fullscreen_label.show()
	color_rect.show()
	fullscreen_ui.show()
	fullscreen_active = true
	
	# Clean up previous tween if exists
	if show_text_tween and show_text_tween.is_running():
		show_text_tween.kill()
	
	# Create new tween for text reveal
	show_text_tween = create_tween()
	show_text_tween.tween_property(fullscreen_label, "visible_ratio", 1.0, show_speed * len(text))
	
	if wait_for_input:
		# Wait for tween to complete
		await show_text_tween.finished
		# Then wait for user input
		await fullscreen_finished
	else:
		# Wait for either tween to complete or timer to run out, whichever is longer
		await get_tree().create_timer(max(show_speed * len(text), display_time)).timeout
		_hide_fullscreen()

func show_fullscreen_image(texture: Texture2D, wait_for_input: bool = true, display_time: float = 2.0) -> void:
	texture_rect.texture = texture
	fullscreen_label.hide()
	texture_rect.show()
	color_rect.show()
	fullscreen_ui.show()
	fullscreen_active = true
	
	if wait_for_input:
		await fullscreen_finished
	else:
		await get_tree().create_timer(display_time).timeout
		_hide_fullscreen()

func _hide_fullscreen() -> void:
	if not fullscreen_active:
		return

	# Hide all UI elements
	fullscreen_ui.hide()
	color_rect.hide()
	fullscreen_label.hide()
	texture_rect.hide()
	
	fullscreen_active = false
	fullscreen_finished.emit()
	
	# Clean up texture to free memory
	if texture_rect and is_instance_valid(texture_rect):
		texture_rect.texture = null