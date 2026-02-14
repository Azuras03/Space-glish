extends Node

# On garde le lecteur audio et le son synthétique
var click_player: AudioStreamPlayer

func _ready() -> void:
	click_player = AudioStreamPlayer.new()
	add_child(click_player)
	click_player.stream = _create_click_stream()

func play_click_sound() -> void:
	if click_player:
		click_player.play()

func _create_click_stream() -> AudioStreamWAV:
	var audio_data := PackedByteArray()
	var sample_rate := 44100.0
	var duration := 0.05
	var frequency := 800.0
	
	for i in range(int(sample_rate * duration)):
		var t = i / sample_rate
		var sample = sin(2.0 * PI * frequency * t) * (1.0 - t/duration)
		var val = int(sample * 32767)
		audio_data.append(val & 0xFF)
		audio_data.append((val >> 8) & 0xFF)
	
	var stream = AudioStreamWAV.new()
	stream.data = audio_data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = int(sample_rate)
	return stream
