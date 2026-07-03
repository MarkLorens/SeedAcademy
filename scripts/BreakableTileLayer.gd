extends TileMapLayer
class_name BreakableTileLayer

## A TileMapLayer whose painted tiles form breakable walls of ANY shape.
## Hitting one cell breaks the entire orthogonally-connected group, so a tall
## column, a thick block, or a short stub all "just work" — the wall is simply
## whatever you paint. Put breakable tiles on their own layer with this script
## and a dedicated collision layer bit so the player's attack can target them.

## Cells counted as "the same wall". Add the diagonals for 8-way connectivity.
const NEIGHBOURS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

## 0 = the whole wall shatters at once. > 0 staggers the break outward from the
## hit cell, one ring per `ripple_delay` seconds, for a crumble effect.
@export var ripple_delay: float = 0.0

# Break the connected wall starting at `start_cell` (map coordinates).
func break_from(start_cell: Vector2i) -> void:
	if get_cell_source_id(start_cell) == -1:
		return  # empty cell, nothing to break

	AudioManager.play_sfx(AudioManager.SFX_OBJECT_BREAK)

	var visited: Dictionary = {start_cell: true}
	var frontier: Array[Vector2i] = [start_cell]

	while not frontier.is_empty():
		var next_frontier: Array[Vector2i] = []
		for cell in frontier:
			erase_cell(cell)  # removes the tile AND its collider
			for offset in NEIGHBOURS:
				var n: Vector2i = cell + offset
				if not visited.has(n) and get_cell_source_id(n) != -1:
					visited[n] = true
					next_frontier.append(n)
		if ripple_delay > 0.0 and not next_frontier.is_empty():
			await get_tree().create_timer(ripple_delay).timeout
		frontier = next_frontier

# Break the wall overlapped by a world-space rectangle (e.g. an attack hitbox).
# Returns true if a tile was found and broken. Resolving the cell from world
# space is reliable, unlike get_coords_for_body_rid which can return the wrong
# coordinate for tilemap collision bodies.
func break_in_global_rect(world_rect: Rect2) -> bool:
	var c0: Vector2i = local_to_map(to_local(world_rect.position))
	var c1: Vector2i = local_to_map(to_local(world_rect.end))
	for x in range(mini(c0.x, c1.x), maxi(c0.x, c1.x) + 1):
		for y in range(mini(c0.y, c1.y), maxi(c0.y, c1.y) + 1):
			var cell := Vector2i(x, y)
			if get_cell_source_id(cell) != -1:
				break_from(cell)  # BFS destroys the whole connected wall
				return true
	return false
