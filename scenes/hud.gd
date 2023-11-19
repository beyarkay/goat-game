class_name Hud
extends CanvasLayer

@onready var skulls = [%left_skull, %right_skull]
@onready var time = %time

func set_health(player: int, health: float) -> void:
	skulls[player - 1].value = 1 - health

func _ready() -> void:
	set_health(1, 1.0)
	set_health(2, 1.0)

	# Connect up the health_change signals
	for player in get_tree().get_nodes_in_group("player"):
		# NOTE: we *cannot* use player.has_signal because it only returns true
		# for signals added via `add_user_signal` ):
		var has_health_change_signal = false
		for signal_entry in player.get_signal_list():
			if signal_entry.name == "health_change":
				has_health_change_signal = true
		assert(
			has_health_change_signal,
			"Player " + player.to_string() + " doesn't have health_change signal"
			)
		player.health_change.connect(_on_health_change)


func _process(delta: float) -> void:
	var seconds: int = Time.get_ticks_msec() / 1000
	var minutes: int = seconds / 60
	seconds -= minutes * 60
	time.text = "%02d:%02d" % [minutes, seconds]

func _on_health_change(player, new_health) -> void:
	set_health(player, new_health / GlobalState.GOAT_HEALTH_MAX)
