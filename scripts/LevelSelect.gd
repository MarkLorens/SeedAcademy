extends Control

# Where the home button returns to.
const MAIN_MENU := "res://ui/Menu/main_menu.tscn"

# Page indicator textures.
const INDICATOR_ON := preload("res://assets/menu/IndicatorOn.png")
const INDICATOR_OFF := preload("res://assets/menu/IndicatorOff.png")

# Level pages come from the LevelManager autoload (the level database).
var levels: Array[level_data] = []

var current := 0

@onready var graphic_button: TextureButton = $CenterContainer/Paper/VBoxContainer/GraphicButton
@onready var title_image: TextureRect = $CenterContainer/Paper/VBoxContainer/VBox/TitleImage
@onready var title_label: Label = $CenterContainer/Paper/VBoxContainer/VBox/TitleLabel
@onready var progress_bar = $CenterContainer/Paper/VBoxContainer/VBox/ProgressBar
@onready var dots: HBoxContainer = $CenterContainer/Paper/VBoxContainer/VBox/Dots
@onready var prev_button: TextureButton = $CenterContainer/Paper/PrevButton
@onready var next_button: TextureButton = $CenterContainer/Paper/NextButton
@onready var home_button: TextureButton = $HomeButton

func _ready() -> void:
	AudioManager.play_menu_music()
	AudioManager.wire_buttons(self)
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
	var data: level_data = levels[current]

	# Title: use the level's title image when it has one, else a plain label.
	title_image.visible = not data.title.is_empty()
	title_label.visible = data.title.is_empty()
	if not data.title.is_empty():
		title_image.texture = load(data.title)
	else:
		title_label.text = data.name if not data.name.is_empty() else "Level %d" % (current + 1)

	# Level doodle — tapping it starts the level. Completed levels show
	# the full graphic instead of the doodle.
	var graphic_path := data.complete_image_path if data.completed and not data.complete_image_path.is_empty() else data.graphic
	graphic_button.texture_normal = load(graphic_path) if not graphic_path.is_empty() else null

	progress_bar.progress = float(data.progress)

	# Dim the graphic when the level is locked or its scene isn't set yet.
	graphic_button.disabled = data.locked or data.scene_path.is_empty()
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
	var data: level_data = levels[current]
	if data.locked or data.scene_path.is_empty():
		return
	# Levels with an opening cinematic go there first; the cinematic
	# chains to the level itself (OpeningScene.next_scene_path).
	if not data.cinematic_path.is_empty():
		get_tree().change_scene_to_file(data.cinematic_path)
	else:
		get_tree().change_scene_to_file(data.scene_path)
