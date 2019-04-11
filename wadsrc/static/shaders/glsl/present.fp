
in vec2 TexCoord;
out vec4 FragColor;

layout(binding=0) uniform sampler2D InputTexture;
uniform float InvGamma;
uniform float Contrast;
uniform float Brightness;
uniform float Saturation;
uniform int GrayFormula;
layout(binding=1) uniform sampler2D DitherTexture;
uniform float ColorScale;

vec4 ApplyGamma(vec4 c)
{
	c.rgb = min(c.rgb, vec3(2.0)); // for HDR mode - prevents stacked translucent sprites (such as plasma) producing way too bright light

	vec3 valgray;
	if (GrayFormula == 0)
		valgray = vec3(c.r + c.g + c.b) * (1 - Saturation) / 3 + c.rgb * Saturation;
	else
		valgray = mix(vec3(dot(c.rgb, vec3(0.3,0.56,0.14))), c.rgb, Saturation);
	vec3 val = valgray * Contrast - (Contrast - 1.0) * 0.5;
	val += Brightness * 0.5;
	val = pow(max(val, vec3(0.0)), vec3(InvGamma));
	return vec4(val, c.a);
}

vec4 Dither(vec4 c)
{
	if (ColorScale == 0.0)
		return c;
	vec2 texSize = vec2(textureSize(DitherTexture, 0));
	float threshold = texture(DitherTexture, gl_FragCoord.xy / texSize).r;
	return vec4(floor(c.rgb * ColorScale + threshold) / ColorScale, c.a);
}

void main()
{
	FragColor = Dither(ApplyGamma(texture(InputTexture, TexCoord)));
}
