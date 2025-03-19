// Vertex shader pour l'intérieur de la pyramide
// Crée une ambiance sombre et mystérieuse

uniform mat4 transform;
uniform mat4 modelview;
uniform mat4 modelviewInv;
uniform mat3 normalMatrix;
uniform vec3 lightPosition;

attribute vec4 vertex;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec2 vertTexCoord;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec3 vertEyeDir;
varying float fogFactor;

void main() {
  // Calcul de la position du vertex dans l'espace de vue
  vec4 vertPosition = modelview * vertex;
  
  // Calcul de la direction de la lumière
  vec3 lightDir = normalize(lightPosition - vertPosition.xyz);
  vertLightDir = lightDir;
  
  // Calcul de la direction de l'œil
  vertEyeDir = normalize(-vertPosition.xyz);
  
  // Calcul de la normale dans l'espace de vue
  vertNormal = normalize(normalMatrix * normal);
  
  // Calcul du facteur de brouillard (fog) pour créer une ambiance plus sombre
  float dist = length(vertPosition.xyz);
  fogFactor = clamp(1.0 - (dist - 20.0) / 80.0, 0.0, 1.0);
  
  // Passage des coordonnées de texture au fragment shader
  vertTexCoord = texCoord;
  
  // Passage de la couleur au fragment shader (teinte bleuâtre pour l'intérieur)
  vertColor = color * vec4(0.7, 0.7, 0.9, 1.0);
  
  // Position finale du vertex
  gl_Position = transform * vertex;
}
