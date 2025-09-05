extends Node3D
# Attach this script to the TV or manage it from a central controller

# Reference to the AudioStreamPlayer node attached to the TV
@onready var tv_audio: VideoStreamPlayer = $SubViewport/SubViewportContainer/VideoStreamPlayer

# Reference to the player node
var player: Node3D = null

func _ready():
	while player == null:
		player = get_tree().get_root().find_child("Player", true, false)
		await get_tree().create_timer(0.1).timeout

func _process(delta):
	if player and tv_audio:
		var distance = global_position.distance_to(player.global_position)
		# Set max_distance (where volume is 0), and min_distance (where volume is max)
		var min_distance = 1.0
		var max_distance = 20.0
		# Clamp and map the distance to a volume range (linear fade)
		var volume = clamp(1.0 - ((distance - min_distance) / (max_distance - min_distance)), 0.0, 1.0)
		# Convert to decibels for Godot (0 is normal, -80 is silent)
		tv_audio.volume_db = lerp(0, -80, 1.0 - volume)
