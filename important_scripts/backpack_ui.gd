# BackpackUI.gd
extends CanvasLayer

# 預載入 UI 小節點
const skill_node_tscn = preload("res://scenes/skill.tscn")
const torch_tscn = preload("res://scenes/torch.tscn")

# Player skill levels and current skill ID are managed locally for UI interaction
# var player_skill_levels: Dictionary = {} # REMOVED: Centralized in ProgressManager
var current_skill_id: String = ""

@onready var detail_popup = $SkillDetailPopup
@onready var popup_title = detail_popup.get_node("Title")
@onready var popup_description = detail_popup.get_node("Description")
@onready var popup_upgradebtn = detail_popup.get_node("UpgradeBtn")
@onready var skill_grid = $TabContainer/人物與技能/SkillGrid
@onready var memories_container = $"TabContainer/永恆之焰的記憶/ScrollContainer/HBoxContainer"
@onready var backpack_root = $"."

func _ready():
	# Initialize skill levels (default to 1)
	# We get the skill data from ProgressManager to know which skills exist
	# for skill_id in ProgressManager.active_skills:
	# 	player_skill_levels[skill_id] = 1 # REMOVED: Logic moved to ProgressManager

	backpack_root.visible = false
	detail_popup.hide()
	setup_backpack()
	
	popup_upgradebtn.pressed.connect(func(): perform_upgrade())

	# ProgressManager signals
	ProgressManager.data_updated.connect(_refresh_ui)
	ProgressManager.memory_collected.connect(_on_memory_collected)
	
	_refresh_ui()

func _process(_delta):
	#  Using default 'ui_focus_next' as E key to toggle backpack
	if Input.is_action_just_pressed("ui_focus_next"):
		backpack_root.visible = !backpack_root.visible
		if backpack_root.visible: _refresh_ui()

func _refresh_ui():
	# Refresh skill levels display
	for skill_node in skill_grid.get_children():
		# if player_skill_levels.has(skill_node.name): # CHECK AGAINST LOCAL
		if ProgressManager.active_skills.has(skill_node.name): # Check if skill is active via ProgressManager
			if skill_node.has_node("VBoxContainer/Level"):
				# skill_node.get_node("VBoxContainer/Level").text = "Lv." + str(player_skill_levels[skill_node.name]) # USE LOCAL
				skill_node.get_node("VBoxContainer/Level").text = "Lv." + str(ProgressManager.get_player_skill_level(skill_node.name)) # USE PROGRESS MANAGER

	# Refresh memory torch states
	var active_memories = ProgressManager.active_memories # Get memories from ProgressManager
	for i in memories_container.get_child_count():
		if i < active_memories.size():
			var torch = memories_container.get_child(i)
			var mem_id = active_memories[i].id
			# Check if memory shard is collected
			var is_collected = ProgressManager.unlocked_memory_ids.has(mem_id)
			torch.refresh_visuals(is_collected)

func open_skill_detail(skill_id: String):
	var skill_data = ProgressManager.get_skill_data(skill_id) # Get skill data from ProgressManager
	if not skill_data: return
	
	current_skill_id = skill_id
	# var lv = player_skill_levels.get(skill_id, 1) # USE LOCAL
	var lv = ProgressManager.get_player_skill_level(skill_id) # USE PROGRESS MANAGER
	var cost = int(skill_data.base_cost * pow(1.5, lv - 1))
	
	# Update popup UI content
	popup_title.text = skill_data.name + " Lv." + str(lv)
	popup_description.text = skill_data.description
	popup_upgradebtn.text = "升級 (消耗 " + str(cost) + " 水晶)"
	detail_popup.show()

# --- Initialize backpack functionality ---
func setup_backpack():
	detail_popup.hide()
	
	# Clear existing dynamic nodes
	for n in skill_grid.get_children(): n.queue_free()
	for n in memories_container.get_children(): n.queue_free()
	
	# Dynamically generate skill nodes
	# Iterate over skills loaded by ProgressManager
	for skill_id in ProgressManager.active_skills:
		var skill_data = ProgressManager.active_skills[skill_id] # This line assumes active_skills is a dictionary mapping ID to data
		
		# Instantiate skill card
		var skill_node = skill_node_tscn.instantiate()
		skill_node.name = skill_id
		skill_grid.add_child(skill_node)
		
		# Get skill card's child nodes
		var vbox = skill_node.get_node("VBoxContainer")
		var icon_node = vbox.get_node("Icon")
		var name_node = vbox.get_node("Name")
		var level_node = vbox.get_node("Level")
		var upgrade_btn = vbox.get_node("UpgradeBtn")
		
		# Setting up skill card elements
		icon_node.texture = skill_data.icon
		name_node.text = skill_data.name
		# Display level from local player_skill_levels
		# level_node.text = "Lv." + str(player_skill_levels.get(skill_id, 1)) # USE LOCAL
		level_node.text = "Lv." + str(ProgressManager.get_player_skill_level(skill_id)) # USE PROGRESS MANAGER
		
		# Connect button press event
		upgrade_btn.pressed.connect(func(): open_skill_detail(skill_id))

	# Dynamically generate memory torches
	# Iterate over memories loaded by ProgressManager
	var active_memories = ProgressManager.active_memories
	for mem_data in active_memories:
		var torch = torch_tscn.instantiate()
		torch.name = mem_data.id
		memories_container.add_child(torch)
		var is_unlocked = ProgressManager.unlocked_memory_ids.has(mem_data.id)
		torch.refresh_visuals(is_unlocked)
		# Connect button press to play cutscene
		torch.pressed.connect(func():
			# Get the memory ID associated with this torch
			var mem_id = mem_data.id
			# Check if the memory has already been collected
			var is_collected = ProgressManager.unlocked_memory_ids.has(mem_id)

			# Close the backpack if it's open
			if backpack_root.visible:
				backpack_root.visible = false

			# If the memory is NOT collected, update the torch state to 'lit'
			# This will play the 'light_torch' animation via refresh_visuals
			if not is_collected:
				torch.refresh_visuals(true)

			# Always play the cutscene associated with this memory
			CutsceneManager.play(mem_data.cutscene_id)
		)
	
	# Refresh UI to ensure initial state is correct
	_refresh_ui()

func _on_memory_collected(memory_id: String):
	# Find the torch corresponding to the collected memory and light it
	var torch = memories_container.get_node_or_null(memory_id)
	if torch:
		torch.refresh_visuals(true)
		print("Torch lit for memory: ", memory_id)

func perform_upgrade():
	if current_skill_id == "": return
	
	var skill_data = ProgressManager.get_skill_data(current_skill_id) # Get skill data from ProgressManager
	if not skill_data: return # Skill data not found
	var lv = ProgressManager.player_skill_levels.get(current_skill_id, 1) # USE LOCAL
	var cost = int(skill_data.base_cost * pow(1.5, lv - 1))

	if ProgressManager.crystal_count >= cost:
		ProgressManager.crystal_count -= cost
		ProgressManager.player_skill_levels[current_skill_id] = lv + 1 # Increment level locally
		ProgressManager.emit_signal("data_updated") # Signal UI refresh
		# Re-open detail window to show updated level
		open_skill_detail(current_skill_id)
	else:
		print("水晶不足") # Not enough crystals

	# Call the centralized upgrade function in ProgressManager
	var success = ProgressManager.upgrade_player_skill(current_skill_id)
	if success:
		# UI will refresh automatically via ProgressManager.data_updated signal
		# Re-open detail window to show updated level and potentially new cost
		open_skill_detail(current_skill_id)
	else:
		print("Skill upgrade failed.") # Error message printed by ProgressManager
