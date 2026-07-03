extends Control

@export_range(0.1, 10.0, 0.1) var fade_in_time := 1.0
@export_range(0.1, 10.0, 0.1) var hold_time := 2.5
@export_range(0.1, 10.0, 0.1) var fade_out_time := 1.0
@export_file("*.tscn") var next_scene_path := "res://ui/Menu/about.tscn"

const IMAGE_DIR := "res://assets/Narasi Akhir/"
const IMAGE_COUNT := 3

@onready var image_display: TextureRect = $ImageDisplay

func _ready() -> void:
	image_display.modulate.a = 0.0
	_play_sequence()
	AudioManager.play_credit_music()

func _play_sequence() -> void:
	for i in range(1, IMAGE_COUNT + 1):
		image_display.texture = load(IMAGE_DIR + "%d.png" % i)
		var tween := create_tween()
		tween.tween_property(image_display, "modulate:a", 1.0, fade_in_time).from(0.0)
		tween.tween_interval(hold_time)
		tween.tween_property(image_display, "modulate:a", 0.0, fade_out_time)
		await tween.finished
	get_tree().change_scene_to_file(next_scene_path)
