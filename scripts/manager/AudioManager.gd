extends Node

## Autoloaded audio manager (registered as "AudioManager" in Project Settings).
## Owns the menu music player and fire-and-forget SFX playback on the
## BGM / SFX buses (see default_bus_layout.tres).

const MUSIC := preload("res://assets/Sounds/Music/MAIN MENU MUSIC.ogg")
const GAMEPLAY_MUSIC := preload("res://assets/Sounds/Music/IN GAME MUSIC.ogg")
const CREDIT_MUSIC := preload("res://assets/Sounds/Music/CREDITS MUSIC.ogg")

const SFX_BUTTON := preload("res://assets/Sounds/Sound Effects/UI/Button.mp3")
const SFX_DASH := preload("res://assets/Sounds/Sound Effects/Fira/Fira Dash.mp3")
const SFX_FAIL := preload("res://assets/Sounds/Sound Effects/Fira/Fira Fail.mp3")
const SFX_SUCCESS := preload("res://assets/Sounds/Sound Effects/Fira/Fira Success.mp3")
const SFX_FROG_JUMP := preload("res://assets/Sounds/Sound Effects/Frog/Frog Jump.mp3")
const SFX_LEVEL_COMPLETE := preload("res://assets/Sounds/Sound Effects/Level Complete/Level Complete.mp3")
const SFX_OBJECT_BREAK := preload("res://assets/Sounds/Sound Effects/UI/Object Break.mp3")
const SFX_SPIKE_TURUN := preload("res://assets/Sounds/Sound Effects/UI/Spike Turun.mp3")
const SFX_ARMADILLO_SKILL := preload("res://assets/Sounds/Sound Effects/Armadillo/Armadillo_Skill.mp3")
const SFX_RHINO_HEADBUTT := preload("res://assets/Sounds/Sound Effects/Rhino/Rhino Headbutt.mp3")

# Keyed by FormData.form_name.
const TRANSFORM_SFX := {
	"human": preload("res://assets/Sounds/Sound Effects/Fira/Fira Transform.mp3"),
	"frog": preload("res://assets/Sounds/Sound Effects/Frog/Frog Transform.mp3"),
	"ape": preload("res://assets/Sounds/Sound Effects/Rhino/Rhino Transform.mp3"),
	"armadillo": preload("res://assets/Sounds/Sound Effects/Armadillo/Armadillo Transform.mp3"),
}

var _music: AudioStreamPlayer

func _ready() -> void:
	# Keep audio alive while the tree is paused (pause / level complete menus).
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music = AudioStreamPlayer.new()
	_music.stream = MUSIC
	_music.bus = &"BGM"
	# Loop regardless of the WAV's import settings.
	_music.finished.connect(_music.play)
	add_child(_music)

## Start the menu music if it isn't already playing. Safe to call from every
## menu's _ready — the track carries on seamlessly between menu scenes.
func play_menu_music() -> void:
	_play_music(MUSIC)

## Start the in-game music. Safe to call from every level's _ready.
func play_gameplay_music() -> void:
	_play_music(GAMEPLAY_MUSIC)
	
func play_credit_music() -> void:
	_play_music(CREDIT_MUSIC)

## Switch to `stream`, restarting only when the track actually changes.
func _play_music(stream: AudioStream) -> void:
	if _music.stream == stream and _music.playing:
		return
	_music.stream = stream
	_music.play()

## Stop the music.
func stop_music() -> void:
	_music.stop()

## Play a one-shot sound on the SFX bus.
func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SFX"
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()

func play_button() -> void:
	play_sfx(SFX_BUTTON)

func play_transform(form_name: String) -> void:
	play_sfx(TRANSFORM_SFX.get(form_name))

## Connect a button click sound to every button under `root`.
func wire_buttons(root: Node) -> void:
	for button in root.find_children("*", "BaseButton", true, false):
		button.pressed.connect(play_button)

## Volume helpers for the pause-menu sliders. `bus` is "BGM" or "SFX",
## `v` is linear 0.0 - 1.0.
func set_volume(bus: String, v: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, v <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.001)))

func get_volume(bus: String) -> float:
	var idx := AudioServer.get_bus_index(bus)
	if idx < 0:
		return 1.0
	if AudioServer.is_bus_mute(idx):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(idx))
