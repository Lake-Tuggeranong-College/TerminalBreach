extends Node3D
# Attach this script to the TV or manage it from a central controller

@onready var player = $Player  # Replace with the actual path to your player node
@onready var video_stream_player = $VideoStreamPlayer  # Replace with your VideoStreamPlayer path

var max_distance = 100.0
var min_volume = 0.0
var max_volume = 1.0

func _process(delta):
	# Calculate the distance between the player and the VideoStreamPlayer
	var distance = player.global_position.distance_to(video_stream_player.global_position)
	
	# Map the distance to a volume value
	var volume = clamp(1.0 - (distance / max_distance), min_volume, max_volume)
	video_stream_player.volume_db = linear_to_db(volume)
