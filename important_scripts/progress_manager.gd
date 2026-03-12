# ProgressManager.gd (Autoload)
extends Node

# --- 版本控制 ---
var is_full_version: bool = false 

# --- 玩家數據 ---
var crystal_count: int = 1000
var current_exp: int = 0
var current_stage_index: int = 0
var unlocked_memory_ids: Array = [] # 儲存已觸碰的記憶 ID (字串)

# --- 核心資料清單 (四個清單) ---
var stages_test = [
	{"name": "開頭動畫", "req_exp": 0, "cutscene": "intro"},
	{"name": "初試身手", "req_exp": 100, "cutscene": "lvl_1"},
	{"name": "結局", "req_exp": 500, "cutscene": "end"}
]
var memories_test = [
	{"id": "m01", "name": "殘留的火種", "desc": "世界毀滅前的最後一絲溫暖。"},
	{"id": "m02", "name": "勇者的遺物", "desc": "曾經有人試圖反抗命運。"}
]

var stages_full = [
	{"name": "開頭動畫", "req_exp": 0, "cutscene": "intro"},
	{"name": "哥布林首都", "req_exp": 1200, "cutscene": "goblin"},
	{"name": "人族首都", "req_exp": 5000, "cutscene": "human_cap"}
]
var memories_full = [
	{"id": "f01", "name": "古老的盟約", "desc": "記載著族人起源的羊皮紙。"},
	{"id": "f02", "name": "末日啟示錄", "desc": "預言了無法逃避的終焉。"}
	# ... 可持續增加
]

# --- 運行時資料參考 ---
var active_stages
var active_memories

signal data_updated
signal memory_collected(memory_id)

func _ready():
	active_stages = stages_full if is_full_version else stages_test
	active_memories = memories_full if is_full_version else memories_test

# 戰鬥結算
func complete_battle(reward_crystals: int, reward_exp: int):
	crystal_count += reward_crystals
	current_exp += reward_exp
	_check_stage_progression()
	emit_signal("data_updated")

func _check_stage_progression():
	if current_stage_index >= active_stages.size() - 1: return
	var next_stage = active_stages[current_stage_index + 1]
	if current_exp >= next_stage.req_exp:
		current_stage_index += 1
		CutsceneManager.play_cutscene(next_stage.cutscene)

# 記憶碎片蒐集
func collect_memory(id: String):
	if not unlocked_memory_ids.has(id):
		unlocked_memory_ids.append(id)
		emit_signal("memory_collected", id)
		emit_signal("data_updated")
		print("成功蒐集記憶碎片: ", id)
