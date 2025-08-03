extends Node2D


@onready var anim_sprite = $AnimatedSprite2D
var current_frame := 0

func _ready():
	pass
	#anim_sprite.play("grow")  # Required to set the animation
	#anim_sprite.stop()
	#anim_sprite.frame = current_frame

var key_pressed_rn := Input.get_axis("ui_left","ui_right")

# Called when the node enters the scene tree for the first time.
#
#var game_file = preload("res://scripts/game.gd").new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		# Handle jump.
	#if Input.is_action_just_pressed("ui_right"):
		#if current_frame < anim_sprite.sprite_frames.get_frame_count("grow") - 1:
			#current_frame += 1
			#anim_sprite.frame = current_frame
		#
	#if Input.is_action_just_pressed("ui_left"):
		#if current_frame > 0:
			#current_frame -= 1
			#anim_sprite.frame = current_frame
