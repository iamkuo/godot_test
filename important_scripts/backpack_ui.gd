# BackpackManager.gd (Autoload)
extends Node

var skill_db = {
	"Skill_1": {"name": "冥火彈", "desc": "燃燒意志轉化的攻擊。", "base_cost": 100},
	"Skill_2": {"name": "骸骨防線", "desc": "召喚古老的守護者。", "base_cost": 250}
}
var player_skill_levels = {"Skill_1": 1, "Skill_2": 1}

@onready var detail_popup: Control = $SkillDetailPopup
var current_skill_id: String = ""

func _ready():
	# 1. 註冊彈窗
	detail_popup = $Popup_SkillDetail
	detail_popup.hide()
	
	# 2. 綁定技能按鈕
	var grid = $TabContainer/人物與技能/HBoxContainer/SkillGrid
	for skill_node in grid.get_children():
		var id = skill_node.name
		skill_node.get_node("UpgradeBtn").pressed.connect(func(): open_skill_detail(id))

	# 3. 綁定彈窗升級按鈕
	$Popup_SkillDetail/PanelContainer/VBox/UpgradeBtn.pressed.connect(func(): perform_upgrade())
	$Popup_SkillDetail/CloseBtn.pressed.connect(func(): $Popup_SkillDetail.hide())
	
	# 4. 監聽更新
	ProgressManager.data_updated.connect(_refresh_ui)
	_refresh_ui()

func _refresh_ui():
	# 刷新技能等級
	var grid = $TabContainer/人物與技能/HBoxContainer/SkillGrid
	for skill_node in grid.get_children():
		if BackpackManager.player_skill_levels.has(skill_node.name):
			skill_node.get_node("Level").text = "Lv." + str(BackpackManager.player_skill_levels[skill_node.name])
	
	# 刷新「永恆之焰記憶」火把狀態
	var timeline = $TabContainer/永恆之焰記憶/ScrollContainer/HBox_Timeline
	var active_mems = ProgressManager.active_memories
	
	for i in timeline.get_child_count():
		var torch = timeline.get_child(i)
		if i < active_mems.size():
			var m_id = active_mems[i].id
			var is_unlocked = ProgressManager.unlocked_memory_ids.has(m_id)
			torch.disabled = !is_unlocked
			torch.modulate = Color(1, 1, 1) if is_unlocked else Color(0.3, 0.3, 0.3)

func open_skill_detail(skill_id: String):
	current_skill_id = skill_id
	var data = skill_db[skill_id]
	var lv = player_skill_levels[skill_id]
	var cost = int(data.base_cost * pow(1.5, lv - 1))
	
	# 更新 UI 內容 (路徑需與場景樹一致)
	detail_popup.get_node("PanelContainer/VBox/Title").text = data.name + " Lv." + str(lv)
	detail_popup.get_node("PanelContainer/VBox/Description").text = data.desc
	detail_popup.get_node("PanelContainer/VBox/UpgradeBtn").text = "升級 (需 " + str(cost) + ")"
	detail_popup.show()

func perform_upgrade():
	if current_skill_id == "": return
	var lv = player_skill_levels[current_skill_id]
	var cost = int(skill_db[current_skill_id].base_cost * pow(1.5, lv - 1))
	
	if ProgressManager.crystal_count >= cost:
		ProgressManager.crystal_count -= cost
		player_skill_levels[current_skill_id] += 1
		ProgressManager.emit_signal("data_updated")
		open_skill_detail(current_skill_id)
