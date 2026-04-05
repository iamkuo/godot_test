extends Node2D
var paused = false
@onready var pause_menu = $GUILayer/Gui/Pause
@onready var gems_label = $GUILayer/Gui/HUD/gems
@onready var hud_button = $GUILayer/Gui/HUD/Button
@onready var player = %Player

func _ready():
	player.coin_amount_changed.connect(_on_player_coin_amount_changed)
	hud_button.pressed.connect(player._on_button_pressed)

func _on_player_coin_amount_changed(new_amount: int):
	gems_label.text = "gems count: " + str(new_amount)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		pause()
func pause():
	if paused :
		pause_menu.visible = true
		Engine.time_scale = 0
	else :
		pause_menu.visible = false
		Engine.time_scale = 1
	paused = !paused


func _on_continue_pressed():
	pass # Replace with function body.


func _on_pausebutton_pressed():
	pause()
