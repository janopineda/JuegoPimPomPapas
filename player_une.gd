extends CharacterBody2D
# Velocidad horizontal
const SPEED = 200
# Fuerza del salto
const JUMP_FORCE = -400
# Gravedad
const GRAVITY = 900

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Movimiento horizontal con teclas
	var input_dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * SPEED

	# Saltar solo si está en el piso
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Mover el cuerpo con la física de Godot
	move_and_slide()
