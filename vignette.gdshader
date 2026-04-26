shader_type canvas_item;

// Allows you to change the color in the Inspector (e.g., dark green or blue)
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float multiplier : hint_range(0.0, 1.0) = 0.1;
uniform float softness : hint_range(0.8, 1.0) = 0.6;

void fragment() {
	// Center the UV coordinates to (0,0) and calculate distance from center
	float value = distance(UV, vec2(0.5));

	// Use smoothstep to create the vignette gradient
	// 'softness' controls how blurry the edges are
	// 'multiplier' controls how much of the screen is covered
	float vignette = smoothstep(multiplier, softness, value);

	// Apply the color and the calculated vignette alpha
	COLOR = vec4(color.rgb, vignette * color.a);
	}