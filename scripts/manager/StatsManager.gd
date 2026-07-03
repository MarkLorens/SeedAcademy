extends Node

## Autoloaded session stats (registered as "StatsManager" in Project Settings).
## Accumulates across every scene for the whole game session; resets when the
## game is closed. Shown by the stats menu (see StatsMenu.gd).

var total_jumps := 0
var total_attempts := 0
var total_time_seconds := 0.0

func add_jump() -> void:
	total_jumps += 1

func add_attempt() -> void:
	total_attempts += 1

func add_play_time(delta: float) -> void:
	total_time_seconds += delta
