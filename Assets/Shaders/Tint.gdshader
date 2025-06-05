/* Shader for the glass in front of the liquid. Renders in front. */

shader_type spatial;

uniform float edge_darkening : hint_range(0.0f, 1.0f);
uniform vec4 glass_color : source_color;

uniform sampler2D label_tex;

void fragment() {
	/* Get label texture. */
	vec4 label_col = texture(label_tex, UV);
	if (label_col.a != 0.0f) {
		/* Render label. */
		ALBEDO = label_col.rgb;
		ALPHA = label_col.a;
	} else {
		/* Render tinted glass. */
		CLEARCOAT = 0.5f;
		CLEARCOAT_ROUGHNESS = 0.5f;
		float d = 1.0f - dot(VIEW, NORMAL);
		ALBEDO = glass_color.rgb;
		ALPHA = edge_darkening * d;
	}
}