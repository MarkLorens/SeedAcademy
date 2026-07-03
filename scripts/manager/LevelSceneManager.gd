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

const PLAYER_START_POS := Vector2i(-100, 280)
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

	Camera.lock_end()
	await get_tree().create_timer(4.0).timeout

	Player.can_move = false
	level_complete_menu.show_level_complete(attempts, int(level_time))

# Reset everything on new game
func new_game(just_died: bool):
	
	if not just_died:
		_show_intro_event()
	else:
		Player.position = PLAYER_START_POS
		# Teleport: skip interpolation this frame so the respawn doesn't smear.
		Player.reset_physics_interpolation()
		# Re-arm any spikes that fell during the previous attempt.
		get_tree().call_group("spikes", "reset")
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
	new_game(true)

func _on_intro_finished() -> void:
	Player.can_move = true
	speed = START_SPEED
	pass
