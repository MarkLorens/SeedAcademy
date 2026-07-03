extends Node

# Exportables
@export var attempt_text: Label
@export var Player: CharacterBody2D
@export var Camera: Camera2D
@export var Event_UI_Scene: PackedScene
@export var intro_lines: Array[String] = [
	"\"Hey you.\"",
	"\"You're finally awake.\"",
	"\"Lorem Ipsum and whatnot.\"",
]

@export var level_complete_checkpoint : Area2D
@export var level_int : int

const PLAYER_START_POS := Vector2(-100, 280)
var attempts := 1
var level_time := 0.0

var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25

var _level_done := false

@onready var pause_menu = $"LevelUI/CanvasLayer/PauseMenu"
@onready var pause_button = $"LevelUI/CanvasLayer/PauseButton/TextureButton"
@onready var level_complete_menu = $"LevelUI/CanvasLayer/LevelCompleteMenu"

func _ready() -> void:
	add_to_group("level_manager")
	AudioManager.stop_music()

	assert(pause_menu, "CRITICAL: PAUSE MENU is not CONNECTED")
	assert(pause_button, "CRITICAL: PAUSE BUTTON is not CONNECTED")
	assert(level_complete_menu, "CRITICAL: LEVEL COMPLETE MENU is not CONNECTED")
	pause_button.pressed.connect(pause_game)

	new_game(false)

func _process(delta: float) -> void:
	if Player and Player.can_move:
		level_time += delta

func pause_game() -> void:
	pause_menu.show_pause()

func level_completed() -> void:
	if _level_done:
		return
	_level_done = true
	LevelManager.complete_level_for_scene(get_tree().current_scene.scene_file_path)

	Camera.lock_end()
	await get_tree().create_timer(4.0).timeout

	Player.can_move = false
	AudioManager.play_sfx(AudioManager.SFX_LEVEL_COMPLETE)
	level_complete_menu.show_level_complete(attempts, int(level_time))

# Reset everything on new game
func new_game(just_died: bool):
	
	if not just_died:
		_show_intro_event()
	else:
		Player.position = PLAYER_START_POS
		# Teleport: skip interpolation this frame so the respawn doesn't smear.
		Player.reset_physics_interpolation()
		# Drop any forms unlocked mid-level (e.g. frog from a checkpoint).
		Player.reset_forms()
		# Re-arm any spikes that fell and rebuild any walls broken last attempt.
		get_tree().call_group("spikes", "reset")
		get_tree().call_group("breakables", "reset")
		attempts += 1
		attempt_text.text = "Attempt %d" % attempts
		attempt_text.get_parent().show()
		
		await get_tree().create_timer(1.0).timeout
		
		attempt_text.get_parent().hide()

func _show_intro_event() -> void:
	Player.velocity = Vector2i(0, 0)
	var eventUI: EventUI = Event_UI_Scene.instantiate()
	eventUI.lines = intro_lines
	add_child(eventUI)
	eventUI.dialogue_finished.connect(_on_intro_finished)

func player_died() -> void:
	AudioManager.play_sfx(AudioManager.SFX_FAIL)
	LevelManager.save_progress_for_scene(get_tree().current_scene.scene_file_path, calculate_progress_percentage())
	new_game(true)

func _on_intro_finished() -> void:
	Player.can_move = true
	speed = START_SPEED
	pass

func calculate_progress_percentage() -> float: 
	var total_path = level_complete_checkpoint.position.x - PLAYER_START_POS.x
	var player_path = Player.position.x - PLAYER_START_POS.x

	# Calculate the progress ratio (0.0 to 1.0) using the dot product
	var progress_ratio = player_path / total_path

	# Clamp the result so progress doesn't go below 0% or above 100%
	var final_progress = clamp(progress_ratio, 0.0, 1.0)

	# Optional: Convert to a percentage (0 to 100)
	print("Total Path: ", total_path)
	print("Player Path: ", player_path)
	print("Progress Ratio: ", progress_ratio)
	
	print(int(final_progress * 100))
	return int(final_progress * 100)
