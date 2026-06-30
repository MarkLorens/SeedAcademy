extends Area2D
class_name DialogueTrigger

## Drop this on an Area2D (with a CollisionShape2D) anywhere in a level,
## then type the dialogue into `lines` in the inspector. When the player
## walks in, the game pauses and EventUI shows the lines.

@export var lines: Array[String] = []
@export var event_ui_scene: PackedScene = preload("res://ui/EventUI.tscn")
@export var pause_game := true
## Fire only the first time the player enters, then remove the trigger.
@export var one_shot := true

var _used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if _used or not body.is_in_group("player"):
		return
	if one_shot:
		_used = true

	var event_ui: EventUI = event_ui_scene.instantiate()
	event_ui.lines = lines
	event_ui.pause_game = pause_game
	get_tree().current_scene.add_child(event_ui)

	if one_shot:
		await event_ui.dialogue_finished
		queue_free()
