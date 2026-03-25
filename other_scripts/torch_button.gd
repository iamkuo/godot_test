extends Control

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Removed debug print to adhere to "only when torch state is changed"
	resized.connect(_on_resized)
	_on_resized()  # Call once on startup
	
	# The 'pressed' signal is emitted by the Button node.
	# The logic for handling state changes (like lighting up if uncollected)
	# should be managed by the UI script (backpack_ui.gd) that connects to this signal.

func _on_resized() -> void:
	# Removed debug print to adhere to "only when torch state is changed"
	# Update sprite scale when control is resized
	if animated_sprite and animated_sprite.sprite_frames:
		# Ensure there's at least one frame to get dimensions from
		var frame_texture = null
		if animated_sprite.sprite_frames.get_frame_texture("lit", 0):
			frame_texture = animated_sprite.sprite_frames.get_frame_texture("lit", 0)
		elif animated_sprite.sprite_frames.get_frame_texture("unlit", 0):
			frame_texture = animated_sprite.sprite_frames.get_frame_texture("unlit", 0)
		
		if frame_texture:
			animated_sprite.scale = Vector2(size.x / frame_texture.get_width(),
											 size.y / frame_texture.get_height())
			# Center the sprite in the control node
			animated_sprite.position = size / 2
		else:
			print("TorchButton: Could not find a frame texture to determine scale.")
