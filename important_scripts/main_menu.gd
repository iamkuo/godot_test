extends Control
@onready var v_box_container = $dabuttons
@onready var panel = $Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	$dabuttons.visible = true
	$Panel.visible = false

func _on_setting_2_pressed():
	$dabuttons.visible = false
	$StartButton2.visible = false
	$Panel.visible = true

func _on_back_2_pressed():
	$Panel.visible = false
	$dabuttons.visible = true
	$StartButton2.visible = true


func _on_pause_pressed():
	$Player/Panel2.visible = true
