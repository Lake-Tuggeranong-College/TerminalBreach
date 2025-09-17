# NetworkManager.gd (Godot 4.x)
extends Node

const MENU_SCENE := "res://Scenes/Worlds/main_menu.tscn" # ← change to your menu scene path

func _ready() -> void:
	# Clients: if the server (host) dies, this fires automatically.
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# ===== Host quits =====
func host_quit_to_menu() -> void:
	if multiplayer.is_server():
		# Tell all clients to go to menu (runs on clients only)
		rpc("return_to_menu", "The host left the session.")
		# Give the RPC a tick to go out
		await get_tree().process_frame
		# Cleanly shut down the server peer
		if multiplayer.multiplayer_peer:
			multiplayer.multiplayer_peer = null
	# Host returns to menu too
	_go_to_menu("You left the session.")

# ===== Clients get kicked by host =====
@rpc("call_remote")
func return_to_menu(reason: String = "") -> void:
	_go_to_menu(reason)

# ===== Clients detect unexpected host disconnect =====
func _on_server_disconnected() -> void:
	_go_to_menu("Lost connection to host.")

func _go_to_menu(reason: String = "") -> void:
	# Optional: show a one–off notice
	if reason != "":
		OS.alert(reason, "Multiplayer")
	get_tree().change_scene_to_file(MENU_SCENE)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
