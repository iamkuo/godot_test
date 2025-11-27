extends Node
@onready var units_container = $Units
@onready var spawn_points = $SpawnPoints
@onready var ui = $UI
@onready var elixir = $Elixir

var local_team:int = 0
var ai_enabled: bool = true
var ai_timer: float = 0.0

func _ready():
	if elixir:
		elixir.connect("elixir_changed", Callable(self,"_on_elixir_changed"))
	if ui:
		var label = ui.get_node("ElixirLabel")
		if label:
			label.text = str(elixir.get_current_int())
	set_process(true)

func _process(delta):
	if ai_enabled:
		ai_timer -= delta
		if ai_timer <= 0.0:
			ai_timer = randf_range(1.0, 3.5)
			#ai_play_card()

func _on_elixir_changed(val:int):
	if ui:
		var label = ui.get_node("ElixirLabel")
		if label:
			label.text = str(val)

func show_message(txt:String):
	if ui:
		var l = ui.get_node("MsgLabel")
		if l:
			l.text = txt

func can_spawn(team:int, cost:int) -> bool:
	if team == local_team:
		return elixir.get_current_int() >= cost
	else:
		return true

func spawn_unit(packed_scene:PackedScene, pos:Vector2, team:int, lane:int):
	if team == local_team:
		if not elixir.try_consume(3):
			show_message("Not enough Elixir")
			return
	var u = packed_scene.instantiate()
	u.global_position = pos
	u.team = team
	u.lane = lane
	units_container.add_child(u)
	u.add_to_group("units")
	if u.has_node("Sprite2D"):
		var s = u.get_node("Sprite2D")
		s.flip_h = (team == 1)

func get_spawn_point(team:int, _lane:int) -> Vector2:
	var pyname = ""
	if team == 0:
		name ="Spawn_L_Top"
		_lane=0
		name = "Spawn_L_Mid"  
		_lane=1
		name = "Spawn_L_Bot"
		_lane=2
	else:
		name ="Spawn_R_Top"
		_lane=0
		name = "Spawn_R_Mid"  
		_lane=1
		name = "Spawn_R_Bot"
		_lane=2
	var p = spawn_points.get_node(pyname)
	if p:
		return p.global_position
	return Vector2.ZERO

func on_tower_destroyed(tower:Node):
	var winner = 1 - tower.team
	show_message("Team %d won!" % winner)
	get_tree().paused = true

#func ai_play_card():
	#var cards = [ 
	#var pick = randi() % cards.size()
	#var lane = randi() % 3
	#var pos = get_spawn_point(1, lane)
	#spawn_unit(cards[pick], pos, 1, lane)
