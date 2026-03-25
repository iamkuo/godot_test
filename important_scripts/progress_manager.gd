extends Node

# --- 1. 常數與資源路徑 ---
const PATH_STAGES = "res://resources/stages/"
const PATH_MEMORIES = "res://resources/memories/"
const PATH_SKILLS = "res://resources/skills/"
const PATH_CUTSCENES = "res://resources/cutscenes/"
const MEMORY_ORDER_PATH = "res://resources/memories/memory_order.tres"
const FALLBACK_ID = "default_failure_cutscene"

# --- 2. 玩家數據與狀態 ---
var crystal_count: int = 1000
var _current_exp: int = 0

var current_exp: int = 0:
	set(value):
		_current_exp = value
		_check_stage_progression()
	get:
		return _current_exp
var current_stage_index: int = -1
var unlocked_memory_ids: Array[String] = []
var player_skill_levels: Dictionary = {} 

# --- 3. 資源快取 ---
var active_stages: Array[StageData] = []
var active_memories: Array[MemoryData] = []
var active_skills: Dictionary = {}
var active_cutscenes: Dictionary = {}

# --- 4. 信號 ---
signal data_updated
signal memory_collected(memory_id: String)

# --- 5. 初始化流程 ---

func _ready() -> void:
	# 初始化基礎資源
	active_stages.assign(_load_resources(PATH_STAGES, StageData).values())
	active_skills = _load_resources(PATH_SKILLS, SkillData)
	active_cutscenes = _load_resources(PATH_CUTSCENES, CutsceneScript)
	
	# 初始化記憶系統 (因涉及排序邏輯，保留獨立提取)
	var all_mems = _load_resources(PATH_MEMORIES, MemoryData)
	var order_res = load(MEMORY_ORDER_PATH) as MemoryOrder
	if order_res:
		for mem_id in order_res.ordered_memory_ids:
			if mem_id in all_mems: active_memories.append(all_mems[mem_id])
	
	_check_stage_progression()

# --- 6. 核心進度邏輯 ---

func _check_stage_progression() -> void:
	var next_idx = current_stage_index + 1
	if active_stages.is_empty() or next_idx >= active_stages.size(): return

	var stage = active_stages[next_idx]
	if current_exp < stage.req_exp: return

	# 符合條件：更新進度
	current_stage_index = next_idx
	
	# 處理記憶收集 (原本的 _try_collect_memory_by_cutscene 已併入此處與 _on_cutscene_finished)
	if not stage.cutscene_id.is_empty():
		for mem in active_memories:
			if mem.cutscene_id == stage.cutscene_id:
				collect_memory(mem.id)
				break
	
	# 處理劇情觸發 (原本的 _handle_stage_unlock 與 _handle_cutscene_fallback 已合併)
	if stage.cutscene_id.is_empty():
		data_updated.emit()
	elif stage.cutscene_id in active_cutscenes:
		CutsceneManager.play(stage.cutscene_id)
	else:
		push_error("[PlayerDataManager] 資源遺失: %s" % stage.cutscene_id)
		if FALLBACK_ID in active_cutscenes:
			CutsceneManager.play(FALLBACK_ID)
		else:
			_on_cutscene_finished("FORCE_SKIP")

# --- 7. 通用工具與對外接口 ---

func _load_resources(path: String, type: GDScript) -> Dictionary:
	var collection = {}
	var dir = DirAccess.open(path)
	if not dir: return collection
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res = load(path + file_name)
			if is_instance_of(res, type) and "id" in res:
				collection[res.id] = res
		file_name = dir.get_next()
	return collection

func collect_memory(id: String) -> void:
	if id not in unlocked_memory_ids:
		unlocked_memory_ids.append(id)
		memory_collected.emit(id)
		data_updated.emit()

func upgrade_player_skill(id: String) -> bool:
	var skill = active_skills.get(id)
	var lv = player_skill_levels.get(id, 1)
	if not skill: return false
	
	var cost = int(skill.base_cost * pow(1.5, lv - 1))
	if crystal_count >= cost:
		crystal_count -= cost
		player_skill_levels[id] = lv + 1
		data_updated.emit()
		return true
	return false

func _on_cutscene_finished(cutscene_id: String) -> void:
	# 劇情結束後檢查是否有對應記憶需解鎖
	for mem in active_memories:
		if mem.cutscene_id == cutscene_id:
			collect_memory(mem.id)
			break

func get_skill_data(skill_id: String) -> SkillData:
	return active_skills.get(skill_id)
