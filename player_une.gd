extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var dash_cooldown_timer = Timer.new()

# Velocidad horizontal
const SPEED = 200
# Fuerza del salto
const JUMP_FORCE = -400
# Gravedad
const GRAVITY = 900

# Contador de saltos
var jump_count = 0
const MAX_JUMPS = 2

var linear_velocity = 0

# --- Variables de Dash ---
const DASH_SPEED = 1000.0   # Velocidad del dash
const DASH_DURATION = 0.15 # Duración del dash en segundos
const DASH_COOLDOWN = 1.0  # Tiempo de espera para volver a usarlo
var can_dash = true
var is_dashing = false
# -------------------------

func _ready():
	# Configurar el temporizador para el cooldown
	dash_cooldown_timer.wait_time = DASH_COOLDOWN
	dash_cooldown_timer.one_shot = true
	add_child(dash_cooldown_timer)
	# Asegúrate de tener una acción de entrada llamada "dash" configurada en Project Settings -> Input Map

#--------- reinicio 
func _process(delta):
	if global_position.y > 1000:
		global_position = Vector2(594, 370)
		velocity = Vector2.ZERO # Usar velocity en lugar de linear_velocity
#----------------------------


func _physics_process(delta):
	# Aplicar gravedad solo si no estamos haciendo dash
	if not is_on_floor() and not is_dashing:
		velocity.y += GRAVITY * delta
	elif not is_dashing:
		# Reinicia el contador cuando toca el suelo, si no estamos haciendo dash
		jump_count = 0

	# Movimiento horizontal con teclas
	var input_dir = Input.get_axis("ui_left", "ui_right")

	# === Lógica del Dash ===
	if Input.is_action_just_pressed("dash") and can_dash:
		_start_dash(input_dir)
		_animated_sprite.play("dash")

	# Si NO estamos haciendo dash, aplicamos movimiento normal
	if not is_dashing:
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

		# Movimiento horizontal normal
		velocity.x = input_dir * SPEED
		
		# Saltar (hasta doble salto)
		if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
			velocity.y = JUMP_FORCE
			jump_count += 1
			_animated_sprite.play("jump")

	# Mover el cuerpo con la física de Godot
	move_and_slide()


# --- Función del Dash ---
func _start_dash(input_dir):
	can_dash = false
	is_dashing = true
	
	# Determinar la dirección del dash
	var dash_direction = Vector2.ZERO
	if input_dir != 0:
		# Dash horizontal si se está moviendo
		dash_direction = Vector2(input_dir, 0)
	else:
		# Si no se mueve, dashea en la dirección actual del sprite
		dash_direction = Vector2(-1 if _animated_sprite.flip_h else 1, 0)

	# Aplicar el impulso del dash (la gravedad se desactiva en _physics_process)
	velocity = dash_direction * DASH_SPEED
	
	# Usar un Tween para manejar la duración del dash y restablecer el estado
	var tween = create_tween()
	tween.tween_interval(DASH_DURATION)
	await tween.finished
	
	# Cuando termina el dash, reactivamos la gravedad y el movimiento normal
	is_dashing = false
	# Opcional: reducir la velocidad horizontal del dash a 0 si no hay input
	if input_dir == 0:
		velocity.x = 0

	# Iniciar el temporizador de cooldown
	dash_cooldown_timer.start()
	await dash_cooldown_timer.timeout
	can_dash = true
