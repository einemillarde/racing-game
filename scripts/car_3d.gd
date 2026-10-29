extends Node3D

@export var speed_label: Label
@export var steering_wheel: Control
@export var throttle_slider: HSlider
@export var brake_slider: HSlider
@export var steering_assist := true

const MAX_ACCELERATION := 25.0
const BRAKING := 40.0
const ROLLING_DRAG := 3.0
const AIR_DRAG := 0.00015
const SLIDE_FRICTION := 200.0
const WHEELBASE := 2.5
const MAX_STEERING_ANGLE := 0.17
const MAX_REVERSE_SPEED := 10.0
const STEERING_ASSIST_CONSTANT := 100.0
const DOWNFORCE_CONSTANT := 0.00021

var velocity := Vector2.ZERO

var steering: float
var throttle: float
var reverse: float
var brake: float

func _physics_process(delta: float) -> void:
    var rot := rotation.y

    var forward := Vector2(sin(rot), cos(rot))
    var right := Vector2(cos(rot), -sin(rot))

    var speed := velocity.dot(forward)
    var slide := velocity.dot(right)

    throttle = move_toward(
        throttle,
        float(Input.is_action_pressed("throttle")),
        2 * delta
    )

    reverse = move_toward(
        reverse,
        float(Input.is_action_pressed("reverse")),
        2 * delta
    )

    brake = move_toward(
        brake,
        float(Input.is_action_pressed("brake")),
        2 * delta
    )

    var assist_value = 1.0 / abs(speed) * STEERING_ASSIST_CONSTANT if steering_assist else 1.0
    steering = move_toward(
        steering,
        float(Input.is_action_pressed("steer right"))
        - float(Input.is_action_pressed("steer left")),
        2 * delta * assist_value
    )

    var acceleration := MAX_ACCELERATION * (throttle - reverse)

    acceleration -= AIR_DRAG * speed * abs(speed)
    speed += acceleration * delta
    speed = move_toward(
        speed, 0,
        (ROLLING_DRAG + BRAKING * brake) * delta
    )

    speed = clamp(speed, -MAX_REVERSE_SPEED, 350)

    var downforce := speed * speed * DOWNFORCE_CONSTANT + 0.25

    slide = move_toward(slide, 0, SLIDE_FRICTION * downforce * delta)

    velocity = forward * speed + right * slide

    if steering != 0:
        rot -= (
            speed / WHEELBASE
            * tan(steering * MAX_STEERING_ANGLE)
            * delta
        )

    rotation.y = rot
    position += Vector3(velocity.x, 0, velocity.y) * delta

    speed_label.text = "%d " % abs(speed)
    steering_wheel.rotation_degrees = steering * 90
    throttle_slider.value = throttle
    brake_slider.value = brake