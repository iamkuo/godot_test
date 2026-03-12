extends Area2D

@export var memory_resource: MemoryData # 直接拖入對應的 .tres

func _ready():
	body_entered.connect(_on_collected)
	# 視覺初始化
	if memory_resource:
		$Sprite2D.texture = memory_resource.icon

func _on_collected(body):
	if body.is_in_group("player"):
		ProgressManager.collect_memory(memory_resource.id)
		# 播放獲得提示或小動畫
		queue_free()
