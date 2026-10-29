shader_type spatial;

uniform sampler2D noise;

float get_height(vec2 pos) {
    float dist_from_center = length(pos);
    float height = texture(noise, pos / 2.0 + 0.5).x;
    return (dist_from_center - 0.5)
        * step(0.5, dist_from_center)
        * 20.0
        * height;
}

void vertex() {
    vec2 pos = VERTEX.xz;

    float epsilon = 0.01;

    float h = get_height(pos);
    float h_left  = get_height(pos - vec2(epsilon, 0.0));
    float h_right = get_height(pos + vec2(epsilon, 0.0));
    float h_back  = get_height(pos - vec2(0.0, epsilon));
    float h_front = get_height(pos + vec2(0.0, epsilon));

    VERTEX.y = h;

    float dx = (h_right - h_left) / (2.0 * epsilon);
    float dz = (h_front - h_back) / (2.0 * epsilon);

    NORMAL = normalize(vec3(-dx, 1.0, -dz));
}

void fragment() {
	ALBEDO = vec3(0.28, 0.75, 0.23);
    NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}
