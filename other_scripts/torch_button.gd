# torch_button.gd
extends Control

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# 將原本的 _on_resized 與 update_state 合併
# 增加一個預設參數 is_unlocked，預設為 null 表示不改變目前狀態，只做縮放
func refresh_visuals(is_unlocked = null) -> void:
	if not animated_sprite or not animated_sprite.sprite_frames:
		return

	# 1. 處理狀態轉變（如果有傳入新狀態）
	if is_unlocked != null:
		if is_unlocked:
			animated_sprite.play("light_torch")
			self.modulate = Color.WHITE
		else:
			animated_sprite.play("unlit")
			self.modulate = Color(0.6, 0.6, 0.6)

	# 2. 處理縮放邏輯（不論狀態是否改變，Resize 時都會跑這裡）
	var current_anim = animated_sprite.animation
	var frame_texture = animated_sprite.sprite_frames.get_frame_texture(current_anim, 0)
	
	if frame_texture:
		animated_sprite.scale = Vector2(size.x / frame_texture.get_width(),
										 size.y / frame_texture.get_height())
		animated_sprite.position = size / 2

func _ready() -> void:
	# 直接連接到合併後的函數，縮放時自動觸發 [cite: 11]
	resized.connect(refresh_visuals)
	# 初始化執行一次
	refresh_visuals()
