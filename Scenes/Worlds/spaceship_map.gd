extends Node3D  # Ensure this matches the new scene’s root node type

@onready var Player = preload("res://Scenes/Player/player.tscn")  # Load player scene
#@onready var main_menu = $CanvasLayer/MainMenu
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var environment = $NavigationRegion3D
@onready var wave_label = $CanvasLayer/HUD/Enemies
@onready var hitmarker = $CanvasLayer/HUD/Hitmarker
@onready var popup_image = $Popupimage
@onready var sound_player = $SoundPlayer
var players = {}
var tracked_player_id = null  # (for local player reference)

var enet_peer = ENetMultiplayerPeer.new()



func _ready():
	#add_player(multiplayer.get_unique_id())
	hitmarker.hide()
	get_tree().paused == false
	print("Single player mode: ", Global.single_player_mode)
	#Global.address_server = "192.168.68.106"
	print("Server: ", Global.address_server)
	if not Global.single_player_mode:
		if Global.address_server:
			# Join multiplayer server
			print("joining")
			var error = enet_peer.create_client(Global.address_server, Global.PORT)

			if error:
				print("error: ", error)
			multiplayer.multiplayer_peer = enet_peer
		else:
			# Host multiplayer server
			print("hosting...")
			var error = enet_peer.create_server(Global.PORT)
			multiplayer.multiplayer_peer = enet_peer
			multiplayer.peer_connected.connect(add_player)
			multiplayer.peer_disconnected.connect(remove_player)
			add_player(multiplayer.get_unique_id())
	#else:
	#	add_player(multiplayer.get_unique_id())

		
		environment.add_to_group("walls")
		
	if Global.single_player_mode == true:
		add_player(multiplayer.get_unique_id())

func _physics_process(_delta):
	if tracked_player_id and players.has(tracked_player_id):
		var local_player = players[tracked_player_id]
		if is_instance_valid(local_player):
			get_tree().call_group("enemy", "update_target_location", local_player.global_transform.origin)


func _unhandled_input(_event):
	if Input.is_action_just_pressed("test world"):
		get_tree().change_scene_to_file("res://Scenes/Worlds/testWorld.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_pressed("toggle_fullscreen"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			

func _process(_delta):
	if Input.is_action_just_pressed("popup_key"):
		# Show image
		popup_image.visible = true
		
		# Play sound from the start
		sound_player.stop()  # make sure it restarts
		sound_player.play()
		# Hide image and stop sound after 1 second
		await get_tree().create_timer(4.38).timeout
		popup_image.visible = false
		sound_player.stop()


func add_player(peer_id):
	if players.has(peer_id):
		return  # Avoid duplicate
	var new_player = Player.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player)
	players[peer_id] = new_player
	
	# If it's the local player
	if new_player.is_multiplayer_authority():
		tracked_player_id = peer_id
		new_player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	if players.has(peer_id):
		var p = players[peer_id]
		if is_instance_valid(p):
			p.queue_free()
		players.erase(peer_id)

	if tracked_player_id == peer_id:
		tracked_player_id = null
		update_health_bar(0)

func update_health_bar(health_value):
	health_bar.value = health_value


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_spaceship_pressed():
	get_tree().change_scene_to_file("res://spaceshipMap.tscn")
	
func _on_multiplayer_spawner_spawned(node):
	print("spawned")
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)

	
