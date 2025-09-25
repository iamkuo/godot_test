extends CharacterBody2D

@export var speed: float = 200.0
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()
	
	 # --- 動畫控制 ---
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				anim_sprite.flip_h = false   # 朝右
				anim_sprite.play("walk_right")
			else:
				anim_sprite.flip_h = true   # 朝左
				anim_sprite.play("walk_right")
		else:
			if input_vector.y > 0:
				anim_sprite.play("walk_down")
			else:
				anim_sprite.play("walk_up")
	else:
		anim_sprite.play("idle_down")  # 這裡假設角色停止時面向下
