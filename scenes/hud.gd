class_name Hud
extends CanvasLayer

@onready var skulls = [%left_skull, %right_skull]
@onready var time = %time

func set_health(player: int, health: float) -> void:
	skulls[player - 1].value = 1 - health

func _ready() -> void:
	set_health(1, 1.0)
	set_health(2, 1.0)

func _process(delta: float) -> void:
	var seconds: int = Time.get_ticks_msec() / 1000
	var minutes: int = seconds / 60
	seconds -= minutes * 60
	time.text = "%02d:%02d" % [minutes, seconds]

func _on_health_change(player, new_health) -> void:
	print("Player %d health changed to %d" % [player, new_health])
	set_health(player, new_health / GlobalState.GOAT_HEALTH_MAX)
