extends AudioStreamPlayer

@export_range(0.0,2.0) var transposition : float
@export_range(60.0,1000.0) var pulse_hz = 144.0 # The frequency of the sound wave.
@export_range(0.01,1.0) var buffer_fill_interval : float

@export var process_sound : bool 

var playback # Will hold the AudioStreamGeneratorPlayback.
@onready var sample_hz = stream.mix_rate


var playback_timer = 0.0
var phase = 0.0

func _ready():
	play()
	playing = true
	playback = get_stream_playback()
	fill_buffer()

func _process(delta):
	if !process_sound: return
	
	playback_timer += delta
	if playback_timer > buffer_fill_interval:
		playback_timer -= buffer_fill_interval
		fill_buffer()

func fill_buffer():
	var increment = pulse_hz / sample_hz
	var frames_available = playback.get_frames_available()

	for i in range(frames_available):
		var sin_wave = Vector2.ONE * sin(phase * TAU)
		var saw_wave = phase * Vector2.ONE
		var square_wave = sign(sin_wave)
		playback.push_frame(lerp(lerp(saw_wave, sin_wave, clamp(transposition, 0, 1)), square_wave, clamp(transposition - 1, 0, 1)))
		phase = fmod(phase + increment, 1.0)
