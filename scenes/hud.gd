class_name Hud
extends CanvasLayer

@onready var skulls = [%left_skull, %right_skull]
@onready var time = %time
@onready var lives = [%left_lives, %right_lives]

func set_health(player: int, health: float) -> void:
	skulls[player - 1].value = 1 - health

func _ready() -> void:
	set_health(1, 1.0)
	set_health(2, 1.0)

	# Connect up the health_change and lives_change signals
	for player in get_tree().get_nodes_in_group("player"):
		player.health_change.connect(_on_health_change)
		player.lives_change.connect(_on_lives_change)


func _process(delta: float) -> void:
	var seconds: int = Time.get_ticks_msec() / 1000
	var minutes: int = seconds / 60
	seconds -= minutes * 60
	time.text = "%02d:%02d" % [minutes, seconds]

func _on_lives_change(player, new_lives) -> void:
	lives[player - 1].set_text(str(new_lives))

func _on_health_change(player, new_health) -> void:
	set_health(player, new_health / GlobalState.GOAT_HEALTH_MAX)
