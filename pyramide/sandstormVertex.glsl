uniform mat4 transform;
uniform mat4 modelview;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  // Position finale du vertex
  gl_Position = transform * position;
  
  // Passage des coordonnées de texture au fragment shader
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
  
  // Passage de la couleur au fragment shader
  vertColor = color;
}
