extends Node

# Variable to hold the AudioStreamPlayer2 node
var audio_player: AudioStreamPlayer

func _ready() -> void:
	# Create a new AudioStreamPlayer2 node and add it as a child of this script
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.autoplay = true  # Optional: Start playing automatically
	audio_player.stream = null   # Set the default stream to null
	audio_player.play()          # Start the player (only if a stream is set)

# Function to set and play a new audio stream
func play_song(song: AudioStream) -> void:
	if audio_player.stream != song:
		audio_player.stream = song
		audio_player.play()
