/* Shader for the liquid surface. Renders behind the liquid. */

shader_type spatial;

render_mode cull_front, shadows_disabled;

uniform vec2 coeff; /* Coefficients of the linear function for the surface. */

uniform float fill_amount : hint_range(0.0f, 1.0f);
uniform float glass_thickness = 0.01f;

uniform float height = 0.32f;
uniform float width = 0.1f;

uniform sampler2D waves_noise;
uniform float wave_intensity = 0.05f;

uniform vec4 liquid_color : source_color;
uniform vec4 glow_color : source_color;

uniform float color_modifier = 1.1f;

uniform float FOV : hint_range(20, 120) = 75;
uniform bool foreground = false;

varying vec3 pos;
varying vec3 normal;
varying float liquid_line;

float lerp(float a, float b, float t) {
	return b * t + a * (1.0f - t);
}

void vertex() {
	if (foreground) {
	    float scale = 1.0 / tan(FOV * 0.5 * PI / -180.0);

	    PROJECTION_MATRIX[0][0] = scale / (-VIEWPORT_SIZE.x / VIEWPORT_SIZE.y);
	    PROJECTION_MATRIX[1][1] = scale;
	}

	// Move vertices inwards to simulate glass thickness.
	VERTEX -= glass_thickness * NORMAL;

	// Position inside container rotated to world.
	pos = mat3(MODEL_MATRIX)*VERTEX;

	// Lerp between height and width depending on world orientation of z axis.
	float d = dot(vec3(MODEL_MATRIX[0][1], MODEL_MATRIX[1][1], MODEL_MATRIX[2][1]), vec3(0.0f, 1.0f, 0.0f));
	float m = lerp(width, height, abs(d));

	// wave noise not working
	liquid_line = (fill_amount - 0.5f) * m
				  + wave_intensity * length(coeff) * (texture(waves_noise, 2.0*pos.xz + 0.5*TIME * vec2(1.0, 1.0)).r - 0.5f
											  	      + texture(waves_noise, 2.0*pos.xz - 0.5*TIME * vec2(1.0, 1.0)).g - 0.5f)
				  + dot(pos.xz, coeff);
}

void fragment() {
	// Set normals depending on incline.
	NORMAL = vec3(coeff.x, 1.0f, coeff.y);

	// Discard all vertices above the liquid line.
	if (pos.y > liquid_line) {
		discard;
	} else {
		ALBEDO = (liquid_color.rgb * color_modifier);
	}

	if (foreground) {
		DEPTH = 1.0 - (1.0 - FRAGCOORD.z) * 0.7;
	} else {
		DEPTH = FRAGCOORD.z;
	}
}

void light() {
	float d = dot(-VIEW, LIGHT);
	float dd = d*d;
	if (d > 0.0f) DIFFUSE_LIGHT = dd * glow_color.rgb;
}