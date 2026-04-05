extends Control

var coin_counter := 0

@onready var gems_label: Label = $MarginContainer/HBoxContainer/gems
@onready var hud_button: Button = $MarginContainer/HBoxContainer/Button

func _ready() -> void:
	hud_button.pressed.connect(_on_hud_button_pressed)
	_refresh_gems_label()
	self.visible = true

func _on_hud_button_pressed() -> void:
	set_coin(coin_counter + 1)

func set_coin(amount: int) -> void:
	coin_counter = amount
	_refresh_gems_label()

func _refresh_gems_label() -> void:
	gems_label.text = "水晶數量: %d" % coin_counter
