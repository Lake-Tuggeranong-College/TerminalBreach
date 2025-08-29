extends Node3D  # Ensure this matches the new scene’s root node type

@onready var Player = preload("res://Scenes/Player/player.tscn")  # Load player scene
# @onready var main_menu = $CanvasLayer/MainMenu
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var environment = $NavigationRegion3D
@onready var wave_label = $CanvasLayer/HUD/Enemies
@onready var hitmarker = $CanvasLayer/HUD/Hitmarker

# Existing popup image + sound
@onready var popup_image = $garmin
@onready var sound_player = $okgarmin

# === Brainrot popup (video + audio) ===
@onready var brainrot_video: VideoStreamPlayer = $BrainrotVideo
@onready var brainrot_audio: AudioStreamPlayer = $Brainrotaudio
@export var brainrot_duration: float = 116.0   # how long the brainrot popup stays
var _brainrot_running := false               # prevents stacking overlaps
# =======================================

var players: Dictionary = {}
var tracked_player_id: int = 0  # (for local player reference)

var enet_peer := ENetMultiplayerPeer.new()

func _ready() -> void:
	hitmarker.hide()
	get_tree().paused = false  # ensure game is unpaused

	print("Single player mode: ", Global.single_player_mode)
	print("Server: ", Global.address_server)

	if not Global.single_player_mode:
		if Global.address_server:
			# Join multiplayer server
			print("joining")
			var error = enet_peer.create_client(Global.address_server, Global.PORT)
			if error != OK:
				print("error: ", error)
			multiplayer.multiplayer_peer = enet_peer
		else:
			# Host multiplayer server
			print("hosting...")
			var error2 = enet_peer.create_server(Global.PORT)
			if error2 != OK:
				print("error: ", error2)
			multiplayer.multiplayer_peer = enet_peer
			multiplayer.peer_connected.connect(add_player)
			multiplayer.peer_disconnected.connect(remove_player)
			add_player(multiplayer.get_unique_id())

		environment.add_to_group("walls")
	else:
		add_player(multiplayer.get_unique_id())

	# --- Brainrot init (safe if nodes missing) ---
	if is_instance_valid(brainrot_video):
		brainrot_video.visible = false
		brainrot_video.loop = false   # we’ll control duration, not loop
	else:
		pass
	if not is_instance_valid(brainrot_audio):
		pass
	# --------------------------------------------

func _physics_process(_delta: float) -> void:
	if tracked_player_id != 0 and players.has(tracked_player_id):
		var local_player = players[tracked_player_id]
		if is_instance_valid(local_player):
			get_tree().call_group("enemy", "update_target_location", local_player.global_transform.origin)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("test world"):
		get_tree().change_scene_to_file("res://Scenes/Worlds/testWorld.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_action_pressed("toggle_fullscreen"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# Brainrot = popup (like the other mode)
	if Input.is_action_just_pressed("brainrot_mode"):
		_play_brainrot_once()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("popup_key"):
		# Show image
		popup_image.visible = true

		# Play sound from the start
		sound_player.stop()
		sound_player.play()

		# Hide image and stop sound after 4.38 seconds
		await get_tree().create_timer(4.38).timeout
		popup_image.visible = false
		sound_player.stop()

# ============= Brainrot popup helpers =============
func _play_brainrot_once() -> void:
	# If the popup is already running, restart both streams cleanly
	if _brainrot_running:
		if is_instance_valid(brainrot_video): brainrot_video.stop()
		if is_instance_valid(brainrot_audio): brainrot_audio.stop()
	# Guard re-entry while the timer runs
	_brainrot_running = true

	# Start video + audio together
	if is_instance_valid(brainrot_video):
		brainrot_video.visible = true
		brainrot_video.play()
	else:
		push_warning("Cannot play Brainrot: BrainrotVideo missing.")
	if is_instance_valid(brainrot_audio):
		brainrot_audio.play(0.0)
	else:
		push_warning("Cannot play Brainrot: Brainrotaudio missing.")

	# Hide/stop after duration
	await get_tree().create_timer(brainrot_duration).timeout

	if is_instance_valid(brainrot_video):
		brainrot_video.stop()
		brainrot_video.visible = false
	if is_instance_valid(brainrot_audio):
		brainrot_audio.stop()

	_brainrot_running = false
# ==================================================

func add_player(peer_id: int) -> void:
	if players.has(peer_id):
		return  # Avoid duplicate
	var new_player: Node3D = Player.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player)
	players[peer_id] = new_player

	# If it's the local player
	if new_player.is_multiplayer_authority():
		tracked_player_id = peer_id
		new_player.health_changed.connect(update_health_bar)

func remove_player(peer_id: int) -> void:
	if players.has(peer_id):
		var p = players[peer_id]
		if is_instance_valid(p):
			p.queue_free()
		players.erase(peer_id)

	if tracked_player_id == peer_id:
		tracked_player_id = 0
		update_health_bar(0)

func update_health_bar(health_value: int) -> void:
	health_bar.value = health_value

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_spaceship_pressed() -> void:
	get_tree().change_scene_to_file("res://spaceshipMap.tscn")

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("spawned")
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)
