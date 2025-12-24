extends Node
## An empty global variable bag with a togglable debug overlay that displays all variables.
##
## Designed to hold simple global variables.
## A bad pattern, but in a game jam, sometimes you just need to get it done.
##
## Displays a debug overlay when the user hits the F1 key.
## All variables are displayed automatically.

## Emitted when any variable changes.
signal changed

signal shells_changed()

var shells: int = 0:
	set(v): shells = v; changed.emit(); shells_changed.emit()

enum ExitLocations {
	GAME_START,
	ISLAND_SHOP_ENTRANCE,
	SHOP_EXIT,
}

var recent_exit_location: ExitLocations = ExitLocations.GAME_START

var total_pockets = 18
var items_in_pockets = []

## Example variable.
var player_health: int = 0:
	set(v): player_health = v; changed.emit()

func _ready():
	for i in range(total_pockets):
		items_in_pockets.push_back(null)

## Reset all variables to their default state.
func reset():
	player_health = 0

#region Debug overlay
var _overlay
func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed:
		match event.physical_keycode:
			KEY_F1:
				if not _overlay:
					_overlay = load("res://autoload/globals/globals_overlay.tscn").instantiate()
					get_parent().add_child(_overlay)
				else:
					_overlay.visible = not _overlay.visible
#endregion
