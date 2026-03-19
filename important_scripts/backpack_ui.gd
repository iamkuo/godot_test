# BackpackUI.gd
extends CanvasLayer

# 預載入 UI 小節點
const skill_node_tscn = preload("res://scenes/skill.tscn")
const torch_tscn = preload("res://scenes/torch.tscn")

# 資源庫
var skill_resources: Dictionary = {} # { "skill_id": SkillData }
var memory_resources: Dictionary = {} # { "memory_id": MemoryData }
var player_skill_levels: Dictionary = {} # { "id": level }

@onready var detail_popup = $SkillDetailPopup
@onready var popup_title = detail_popup.get_node("Title")
@onready var popup_description = detail_popup.get_node("Description")
@onready var popup_upgradebtn = detail_popup.get_node("UpgradeBtn")
@onready var skill_grid = $TabContainer/人物與技能/SkillGrid
@onready var memories_container = $"TabContainer/永恆之焰的記憶/ScrollContainer/HBoxContainer"
@onready var backpack_root = $"."

var current_skill_id: String = ""

func _ready():
	# 加載所有技能和記憶資源
	_load_resources()
	# 隱藏背包
	backpack_root.visible = false
	detail_popup.hide()
	setup_backpack()
	# 綁定彈窗升級按鈕
	popup_upgradebtn.pressed.connect(func(): perform_upgrade())
	# 監聽更新
	ProgressManager.data_updated.connect(_refresh_ui)
	_refresh_ui()

func _process(_delta):
	# 按 E 鍵開啟/關閉背包
	if Input.is_action_just_pressed("ui_focus_next"):  # E 鍵默認映射
		toggle_backpack()

func toggle_backpack():
	backpack_root.visible = !backpack_root.visible
	if backpack_root.visible:
		_refresh_ui()

# --- 資源加載 ---
func _load_resources():
	# 從 res://resources/skills/ 加載所有技能
	_load_skills_from_directory("res://resources/skills/")
	# 從 res://resources/memories/ 加載所有記憶
	_load_memories_from_directory("res://resources/memories/")
	print("已加載 %d 個技能和 %d 個記憶" % [skill_resources.size(), memory_resources.size()])

func _load_skills_from_directory(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load(dir_path + file_name)
				if resource is SkillData and not resource.id.is_empty():
					skill_resources[resource.id] = resource
					player_skill_levels[resource.id] = 1
					print("已加載技能: %s (%s)" % [resource.name, resource.id])
			file_name = dir.get_next()

func _load_memories_from_directory(dir_path: String):
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var resource = load(dir_path + file_name)
				if resource is MemoryData and not resource.id.is_empty():
					memory_resources[resource.id] = resource
					print("已加載記憶: %s (%s)" % [resource.name, resource.id])
			file_name = dir.get_next()

func _refresh_ui():
	# 刷新技能等級顯示
	for skill_node in skill_grid.get_children():
		if player_skill_levels.has(skill_node.name):
			if skill_node.has_node("VBoxContainer/Level"):
				skill_node.get_node("VBoxContainer/Level").text = "Lv." + str(player_skill_levels[skill_node.name])
	
	# 刷新永恆之焰的記憶火把狀態 (使用加載的記憶資源)
	var memory_list = memory_resources.values()
	for i in memories_container.get_child_count():
		if i < memory_list.size():
			var torch = memories_container.get_child(i)
			var mem_id = memory_list[i].id
			var is_unlocked = ProgressManager.unlocked_memory_ids.has(mem_id)
			# 控制火把動畫和顏色
			if torch.has_node("AnimationPlayer"):
				var torch_anim = torch.get_node("AnimationPlayer")
				torch_anim.play("lit" if is_unlocked else "unlit")
			torch.modulate = Color(1, 1, 1) if is_unlocked else Color(0.6, 0.6, 0.6)


func open_skill_detail(skill_id: String):
	if not skill_resources.has(skill_id): return
	
	current_skill_id = skill_id
	var data = skill_resources[skill_id]
	var lv = player_skill_levels[skill_id]
	var cost = int(data.base_cost * pow(1.5, lv - 1))
	
	# 更新彈窗 UI 內容
	popup_title.text = data.name + " Lv." + str(lv)
	popup_description.text = data.description
	popup_upgradebtn.text = "升級 (消耗 " + str(cost) + " 水晶)"
	detail_popup.show()



# --- 初始化背包功能 ---
func setup_backpack():
	detail_popup.hide()
	
	# 清空舊有動態節點
	for n in skill_grid.get_children(): n.queue_free()
	for n in memories_container.get_children(): n.queue_free()
	
	# 動態生成技能節點 (使用加載的技能資源)
	for skill_id in skill_resources:
		var skill_data = skill_resources[skill_id]
		
		# 實例化技能卡片
		var skill_node = skill_node_tscn.instantiate()
		skill_node.name = skill_id
		skill_grid.add_child(skill_node)
		
		# 獲取技能卡片的各個子節點
		var vbox = skill_node.get_node("VBoxContainer")
		var icon_node = vbox.get_node("Icon")
		var name_node = vbox.get_node("Name")
		var level_node = vbox.get_node("Level")
		var upgrade_btn = vbox.get_node("UpgradeBtn")
		
		# 設置技能卡片內容
		_setup_skill_node(icon_node, name_node, level_node, skill_data)
		
		# 綁定按鈕點擊事件
		upgrade_btn.pressed.connect(func(): open_skill_detail(skill_id))

	# 動態生成永恆之焰的記憶火把 (使用加載的記憶資源)
	for mem_id in memory_resources:
		var torch = torch_tscn.instantiate()
		torch.name = mem_id
		memories_container.add_child(torch)

func _setup_skill_node(icon_node: TextureRect, name_node: Label, level_node: Label, skill_data: SkillData):
	# 設置技能卡片的各個元素
	icon_node.texture = skill_data.icon
	name_node.text = skill_data.name
	level_node.text = "Lv." + str(player_skill_levels[skill_data.id])

func perform_upgrade():
	if current_skill_id == "": return
	if not skill_resources.has(current_skill_id): return
	
	var skill_data = skill_resources[current_skill_id]
	var lv = player_skill_levels[current_skill_id]
	var cost = int(skill_data.base_cost * pow(1.5, lv - 1))
	
	if ProgressManager.crystal_count >= cost:
		ProgressManager.crystal_count -= cost
		player_skill_levels[current_skill_id] += 1
		ProgressManager.emit_signal("data_updated")
		# 重新打開詳細視窗以顯示升級後的等級
		open_skill_detail(current_skill_id)
	else:
		print("水晶不足")

# --- 輔助函式 ---
