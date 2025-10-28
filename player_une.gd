extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

# Velocidad horizontal
const SPEED = 200
# Fuerza del salto
const JUMP_FORCE = -400
# Gravedad
const GRAVITY = 900

# Contador de saltos
var jump_count = 0
const MAX_JUMPS = 2

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		# Reinicia el contador cuando toca el suelo
		jump_count = 0

	# Movimiento horizontal con teclas
	var input_dir = Input.get_axis("ui_left", "ui_right")

	# Animaciones según estado
	if not is_on_floor():
		_animated_sprite.play("jump")
	elif input_dir != 0:
		_animated_sprite.play("walk")
	else:
		_animated_sprite.play("idle")

	# Flip horizontal del sprite según la dirección
	if input_dir < 0:
		_animated_sprite.flip_h = true
	elif input_dir > 0:
		_animated_sprite.flip_h = false

	# Movimiento horizontal
	velocity.x = input_dir * SPEED

	# Saltar (hasta doble salto)
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_FORCE
		jump_count += 1
		_animated_sprite.play("jump")

	# Mover el cuerpo con la física de Godot
	move_and_slide()
