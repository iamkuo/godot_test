extends Node

# =============================
# Constants and Exports
# =============================
@export var show_speed: float = 0.02  # 每個字元顯示的秒數

# =============================
# Dialog UI References
# =============================
var dialog: Control
var text_label: Label
var text_end: Label

# =============================
# Fullscreen UI References
# =============================
@onready var fullscreen_ui: Control
@onready var color_rect: ColorRect
@onready var fullscreen_label: Label
@onready var texture_rect: TextureRect

# =============================
# State Variables
# =============================
var dialog_tween: Tween = null
var fullscreen_tween: Tween = null
var current_state = gui_state.READY
var text_queue: Array[String] = []
var fullscreen_queue: Array[Dictionary] = []
var current_fullscreen_item: Dictionary = {}
var current_mode: String = ""  # "dialog" or "fullscreen"
var ui_initialized: bool = false

# =============================
# Enums
# =============================
enum gui_state {
	READY,
	DIALOG_READING,
	DIALOG_FINISHED,
	FULLSCREEN_READING,
	FULLSCREEN_FINISHED
}

# =============================
# Signals
# =============================
signal dialog_finished()
signal fullscreen_finished()

func _ready() -> void:
	await get_tree().process_frame
	print("GUI Manager: Initializing...")
	dialog = get_node("/root/Game/GUI/Dialog") as Control
	text_label = dialog.get_node("HBoxContainer/Label") as Label
	text_end = dialog.get_node("HBoxContainer/End") as Label
	fullscreen_ui = get_node("/root/Game/GUI/FullscreenUI") as Control
	color_rect = fullscreen_ui.get_node("ColorRect") as ColorRect
	fullscreen_label = fullscreen_ui.get_node("Label") as Label
	texture_rect = fullscreen_ui.get_node("TextureRect") as TextureRect
	print("GUI Manager: Nodes initialized successfully")

	_hide_text()
	_hide_fullscreen()
	print("GUI Manager: Ready state, current_state: ", current_state)
	
func _process(_delta: float) -> void:
	# Process unified state machine
	match current_state:
		gui_state.READY:
			# Check for pending items with proper mutual exclusion
			# Fullscreen items have priority over dialog items
			if !fullscreen_queue.is_empty() and current_mode != "dialog":
				print("GUI Manager: Processing fullscreen queue, items: ", fullscreen_queue.size())
				_show_fullscreen_item()
			elif !text_queue.is_empty() and current_mode != "fullscreen":
				print("GUI Manager: Processing text queue, items: ", text_queue.size())
				_show_text()
		
		gui_state.DIALOG_READING:
			if Input.is_action_just_pressed("ui_accept"):
				if dialog_tween:
					dialog_tween.kill()
					dialog_tween = null
				text_label.visible_ratio = 1.0
				text_end.text = "v"
				_change_state(gui_state.DIALOG_FINISHED)
		
		gui_state.DIALOG_FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				if !text_queue.is_empty():
					_show_text()
				else:
					_hide_text()
					emit_signal("dialog_finished")
					_change_state(gui_state.READY)
		
		gui_state.FULLSCREEN_READING:
			if Input.is_action_just_pressed("ui_accept"):
				if fullscreen_tween:
					fullscreen_tween.kill()
					fullscreen_tween = null
				if current_fullscreen_item.has("text"):
					fullscreen_label.visible_ratio = 1.0
					_change_state(gui_state.FULLSCREEN_FINISHED)
		
		gui_state.FULLSCREEN_FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				_show_fullscreen_item()
				if fullscreen_queue.is_empty():
					_hide_fullscreen()
					emit_signal("fullscreen_finished")
					_change_state(gui_state.READY)

# =============================
# Utility Functions
# =============================

func _cleanup_all_tweens() -> void:
	# Clean up any active tweens to prevent conflicts
	if dialog_tween:
		dialog_tween.kill()
		dialog_tween = null
	if fullscreen_tween:
		fullscreen_tween.kill()
		fullscreen_tween = null

func reset_gui_state() -> void:
	# Reset all state variables for error recovery
	_cleanup_all_tweens()
	current_state = gui_state.READY
	current_mode = ""
	text_queue.clear()
	fullscreen_queue.clear()
	current_fullscreen_item.clear()
	_hide_text()
	_hide_fullscreen()

# =============================
# Dialog Functions
# =============================
func queue_text(next_text: String) -> void:
	print("GUI Manager: Queueing text: ", next_text)
	text_queue.push_back(next_text)
	
func queue_texts(texts: Array[String]) -> void:
	print("GUI Manager: Queueing ", texts.size(), " texts")
	for t in texts:
		print("GUI Manager: - ", t)
		text_queue.push_back(t)

func _hide_text() -> void:
		text_label.text = ""
		text_end.text = ""
		dialog.hide()

func _show_text() -> void:
	_change_state(gui_state.DIALOG_READING)
	current_mode = "dialog"
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
	_change_state(gui_state.DIALOG_FINISHED)

func _change_state(next_state: int) -> void:
	var previous_state = current_state
	current_state = next_state as gui_state
	print("GUI state changed from %s to %s" % [gui_state.keys()[previous_state],
	gui_state.keys()[current_state]])



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
	
	var item = fullscreen_queue.pop_front()
	current_fullscreen_item = item
	current_mode = "fullscreen"
	
	if item.type == "text":
		_change_state(gui_state.FULLSCREEN_READING)
		var text = item.text
		fullscreen_label.text = text
		fullscreen_label.visible_ratio = 0
		texture_rect.hide()
		# Position and size the label to cover the full screen
		fullscreen_label.anchors_preset = Control.PRESET_FULL_RECT
		fullscreen_label.position = Vector2.ZERO
		fullscreen_label.size = get_viewport().get_visible_rect().size
		fullscreen_label.show()
		color_rect.color = Color(0, 0, 0, 1)  # Set to solid black
		color_rect.scale = Vector2(1, 1)  # Reset scale to ensure visibility
		color_rect.show()
		fullscreen_ui.show()
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
		_change_state(gui_state.FULLSCREEN_FINISHED)
	elif item.type == "image":
		_change_state(gui_state.FULLSCREEN_READING)
		var texture = item.texture
		texture_rect.texture = texture
		fullscreen_label.hide()
		# Position and size the texture rect to cover the full screen
		texture_rect.anchors_preset = Control.PRESET_FULL_RECT
		texture_rect.position = Vector2.ZERO
		texture_rect.size = get_viewport().get_visible_rect().size
		texture_rect.show()
		color_rect.color = Color(0, 0, 0, 1)  # Set to solid black
		color_rect.scale = Vector2(1, 1)  # Reset scale to ensure visibility
		color_rect.show()
		fullscreen_ui.show()
		# Images go to FINISHED state for consistency
		_change_state(gui_state.FULLSCREEN_FINISHED)

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
	current_fullscreen_item.clear()
	
	# Clean up texture to free memory
	texture_rect.texture = null
