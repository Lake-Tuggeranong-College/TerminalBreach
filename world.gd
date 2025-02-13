extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar


@onready var Player = preload("res://Scenes/player.tscn")
#@onready var Player = $Player
var tracked = false
var player


func _physics_process(delta):
	if tracked:
		get_tree().call_group("enemy", "update_target_location", player.global_transform.origin)

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_single_player_button_pressed():
	main_menu.hide()
	hud.show()
	#multiplayer.multiplayer_peer = enet_peer
	add_player(multiplayer.get_unique_id())


func add_player(peer_id):
	player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	tracked = true
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value
