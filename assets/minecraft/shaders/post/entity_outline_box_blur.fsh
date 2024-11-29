#version 150

uniform sampler2D InSampler;

in vec2 texCoord;
in vec2 sampleStep;

out vec4 fragColor;

void main() {

    fragColor = texture(InSampler, texCoord + sampleStep * 0.0001);
    
}