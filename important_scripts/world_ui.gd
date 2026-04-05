extends CanvasLayer

# =============================
# Node References
# =============================
@onready var hud: Control = $HUD
@onready var pause_menu: Control = $Pause

# =============================
# Public API (forwarded to children)
# =============================
func set_coin(amount: int) -> void:
	hud.set_coin(amount)
