class_name GoatSounds
extends Node

@onready var step_sounds: Array[AudioStreamPlayer2D] = [
	$step1 as AudioStreamPlayer2D,
	$step2 as AudioStreamPlayer2D,
	$step3 as AudioStreamPlayer2D
]
@onready var snort_sounds: Array[AudioStreamPlayer2D] = [
	$snort1 as AudioStreamPlayer2D,
	$snort2 as AudioStreamPlayer2D
]

@onready var bleat_sounds: Array[AudioStreamPlayer2D] = [
	$bleat1 as AudioStreamPlayer2D,
	$bleat2 as AudioStreamPlayer2D,
	$bleat3 as AudioStreamPlayer2D,
	$bleat4 as AudioStreamPlayer2D,
	$bleat5 as AudioStreamPlayer2D
]

@onready var charge_hit_sound: AudioStreamPlayer2D = $charge_hit as AudioStreamPlayer2D
@onready var charge_sound: AudioStreamPlayer2D = $charge as AudioStreamPlayer2D
@onready var charge_volume: AnimationPlayer = $charge_volume as AnimationPlayer
@onready var slam_sound: AudioStreamPlayer2D = $slam as AudioStreamPlayer2D
@onready var headbutt_sound: AudioStreamPlayer2D = $headbutt as AudioStreamPlayer2D

func play_random(list: Array[AudioStreamPlayer2D], low = 0.75, hi = 1.3) -> void:
	var sound = list[randi_range(0, list.size() - 1)]
	sound.pitch_scale = randf_range(low, hi)
	sound.play()

func step() -> void:
	play_random(step_sounds)

func snort() -> void:
	play_random(snort_sounds)

func bleat() -> void:
	play_random(bleat_sounds, 0.65, 1.2)

func charge_hit() -> void:
	charge_hit_sound.play()
	stop_charge()

func start_charge() -> void:
	charge_volume.play("fade_in")
	charge_sound.play()

func stop_charge() -> void:
	charge_sound.stop()
	
func slam(hit: bool) -> void:
	if hit: slam_sound.volume_db = 10
	else: slam_sound.volume_db = -1
	slam_sound.play()

func headbutt() -> void:
	headbutt_sound.play()
