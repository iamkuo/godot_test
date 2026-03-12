# BackpackManager.gd
extends Node

# 預載入 UI 小節點
const SKILL_NODE_TSCN = preload("res://scenes/ui/skill.tscn")
const TORCH_NODE_TSCN = preload("res://scenes/ui/torch.tscn")

# 資源庫
@export var skill_resources: Array[SkillData] = []
var player_skill_levels: Dictionary = {} # { "id": level }

# UI 代理參照
var detail_popup: Control = null
var current_skill_id: String = ""

# --- 初始化背包功能 ---
func setup_backpack(skill_grid: GridContainer, memory_hbox: HBoxContainer, popup: Control):
	detail_popup = popup
	detail_popup.hide()
	
	# 1. 清空舊有動態節點
	for n in skill_grid.get_children(): n.queue_free()
	for n in memory_hbox.get_children(): n.queue_free()
	
	# 2. 動態生成技能
	for skill in skill_resources:
		if not player_skill_levels.has(skill.id): player_skill_levels[skill.id] = 1
		
		var node = SKILL_NODE_TSCN.instantiate()
		skill_grid.add_child(node)
		_update_skill_ui_node(node, skill)
		
		# 點擊開啟詳細視窗
		node.get_node("UpgradeBtn").pressed.connect(func(): open_skill_detail(skill.id))

	# 3. 動態生成記憶 (火炬)
	for mem in ProgressManager.active_memories:
		var torch = TORCH_NODE_TSCN.instantiate()
		memory_hbox.add_child(torch)
		_update_torch_ui_node(torch, mem)

# --- 詳細資訊彈窗與升級 ---
func open_skill_detail(id: String):
	current_skill_id = id
	var data = _get_skill_data(id)
	var lv = player_skill_levels[id]
	var cost = int(data.base_cost * pow(1.5, lv - 1))
	
	detail_popup.get_node("PanelContainer/VBox/Title").text = data.name + " Lv." + str(lv)
	detail_popup.get_node("PanelContainer/VBox/Description").text = data.description
	detail_popup.get_node("PanelContainer/VBox/UpgradeBtn").text = "消耗 " + str(cost) + " 水晶升級"
	detail_popup.show()

func perform_upgrade():
	var data = _get_skill_data(current_skill_id)
	var lv = player_skill_levels[current_skill_id]
	var cost = int(data.base_cost * pow(1.5, lv - 1))
	
	if ProgressManager.crystal_count >= cost:
		ProgressManager.crystal_count -= cost
		player_skill_levels[current_skill_id] += 1
		ProgressManager.emit_signal("data_updated")
		open_skill_detail(current_skill_id) # 重新渲染彈窗
	else:
		print("水晶不足")

# --- 輔助函式 ---
func _update_skill_ui_node(node, data):
	node.get_node("Icon").texture = data.icon
	node.get_node("Level").text = "Lv." + str(player_skill_levels[data.id])

func _update_torch_ui_node(node, data):
	var is_unlocked = ProgressManager.unlocked_memory_ids.has(data.id)
	node.disabled = !is_unlocked
	node.modulate = Color(1, 1, 1) if is_unlocked else Color(0.2, 0.2, 0.2)

func _get_skill_data(id: String) -> SkillData:
	for s in skill_resources:
		if s.id == id: return s
	return null
