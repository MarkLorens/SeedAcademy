extends Control

# Where the home button returns to.
const MAIN_MENU := "res://ui/Menu/main_menu.tscn"

# Page indicator textures.
const INDICATOR_ON := preload("res://assets/menu/IndicatorOn.png")
const INDICATOR_OFF := preload("res://assets/menu/IndicatorOff.png")

# Level pages come from the LevelManager autoload (the level database).
var levels: Array[Dictionary] = []

var current := 0

@onready var graphic_button: TextureButton = $CenterContainer/Paper/VBox/GraphicButton
@onready var title_image: TextureRect = $CenterContainer/Paper/VBox/TitleImage
@onready var title_label: Label = $CenterContainer/Paper/VBox/TitleLabel
@onready var progress_bar = $CenterContainer/Paper/VBox/ProgressBar
@onready var dots: HBoxContainer = $CenterContainer/Paper/VBox/Dots
@onready var prev_button: TextureButton = $PrevButton
@onready var next_button: TextureButton = $NextButton
@onready var home_button: TextureButton = $HomeButton

func _ready() -> void:
	levels = LevelManager.levels
	graphic_button.pressed.connect(_on_play_pressed)
	prev_button.pressed.connect(func(): _go(current - 1))
	next_button.pressed.connect(func(): _go(current + 1))
	home_button.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU))
	_build_dots()
	_refresh()

# One dot per level, used as a simple page indicator.
func _build_dots() -> void:
	for child in dots.get_children():
		child.queue_free()

	for i in levels.size():
		var dot := TextureRect.new()
		dot.texture = INDICATOR_OFF
		dot.custom_minimum_size = Vector2(40, 42)
		dot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		dot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		dots.add_child(dot)

func _go(index: int) -> void:
	current = clampi(index, 0, levels.size() - 1)
	_refresh()

# Update everything to reflect the current page.
func _refresh() -> void:
	var data: Dictionary = levels[current]

	# Title: use the level's title image when it has one, else a plain label.
	var title_path := str(data.get("title", ""))
	title_image.visible = not title_path.is_empty()
	title_label.visible = title_path.is_empty()
	if not title_path.is_empty():
		title_image.texture = load(title_path)
	else:
		title_label.text = str(data.get("name", "Level %d" % (current + 1)))

	# Level doodle — tapping it starts the level.
	var graphic_path := str(data.get("graphic", ""))
	graphic_button.texture_normal = load(graphic_path) if not graphic_path.is_empty() else null

	progress_bar.progress = float(data.get("progress", 0.0))

	# Dim the graphic when this level's scene isn't set yet.
	var scene_path := str(data.get("scene", ""))
	graphic_button.disabled = scene_path.is_empty()
	graphic_button.modulate = Color(1, 1, 1, 0.4) if graphic_button.disabled else Color.WHITE

	# Arrows stop at the ends.
	prev_button.disabled = current <= 0
	next_button.disabled = current >= levels.size() - 1
	prev_button.modulate = Color(1, 1, 1, 0.4) if prev_button.disabled else Color.WHITE
	next_button.modulate = Color(1, 1, 1, 0.4) if next_button.disabled else Color.WHITE

	# Highlight the active dot.
	for i in dots.get_child_count():
		var dot := dots.get_child(i) as TextureRect
		dot.texture = INDICATOR_ON if i == current else INDICATOR_OFF

func _on_play_pressed() -> void:
	var scene_path := str(levels[current].get("scene", ""))
	if not scene_path.is_empty():
		get_tree().change_scene_to_file(scene_path)
