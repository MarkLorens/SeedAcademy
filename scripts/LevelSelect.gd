extends Control

# Where "Back" returns to.
const MAIN_MENU := "res://ui/Menu/main_menu.tscn"

# One entry per level page. Leave "scene" empty for levels that don't exist yet —
# their Play button will be disabled, but you can still page to them.
@export var levels: Array[Dictionary] = [
	{ "name": "Level 1", "scene": "res://scenes/level_1.tscn" },
	{ "name": "Level 2", "scene": "" },
	{ "name": "Level 3", "scene": "" },
]

var current := 0

@onready var level_name_label: Label = $CenterContainer/VBox/LevelNameLabel
@onready var play_button: Button = $CenterContainer/VBox/PlayButton
@onready var dots: HBoxContainer = $CenterContainer/VBox/Dots
@onready var prev_button: Button = $PrevButton
@onready var next_button: Button = $NextButton
@onready var back_button: Button = $BackButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	prev_button.pressed.connect(func(): _go(current - 1))
	next_button.pressed.connect(func(): _go(current + 1))
	back_button.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU))
	_build_dots()
	_refresh()

# One dot per level, used as a simple page indicator.
func _build_dots() -> void:
	for child in dots.get_children():
		child.queue_free()
	for i in levels.size():
		var dot := Label.new()
		dot.text = "●"
		dots.add_child(dot)

func _go(index: int) -> void:
	current = clampi(index, 0, levels.size() - 1)
	_refresh()

# Update everything to reflect the current page.
func _refresh() -> void:
	var data: Dictionary = levels[current]
	level_name_label.text = str(data.get("name", "Level %d" % (current + 1)))

	# Disable Play when this level's scene isn't set yet.
	var scene_path := str(data.get("scene", ""))
	play_button.disabled = scene_path.is_empty()
	play_button.text = "Play" if not play_button.disabled else "Coming soon"

	# Arrows stop at the ends.
	prev_button.disabled = current <= 0
	next_button.disabled = current >= levels.size() - 1

	# Highlight the active dot.
	for i in dots.get_child_count():
		var dot := dots.get_child(i) as Label
		dot.modulate = Color.WHITE if i == current else Color(1, 1, 1, 0.35)

func _on_play_pressed() -> void:
	var scene_path := str(levels[current].get("scene", ""))
	if not scene_path.is_empty():
		get_tree().change_scene_to_file(scene_path)
