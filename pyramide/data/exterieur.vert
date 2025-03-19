// Vertex shader pour l'extérieur de la pyramide
// Crée une ambiance claire et ensoleillée

uniform mat4 transform;
uniform mat4 modelview;
uniform mat4 modelviewInv;
uniform mat3 normalMatrix;

attribute vec4 vertex;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec2 vertTexCoord;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying float vertLightIntensity;

void main() {
  // Calcul de la position du vertex dans l'espace de vue
  vec4 vertPosition = modelview * vertex;
  
  // Direction de la lumière (soleil) - fixe pour tous les vertices
  vertLightDir = normalize(vec3(0.5, 0.5, -1.0));
  
  // Calcul de la normale dans l'espace de vue
  vertNormal = normalize(normalMatrix * normal);
  
  // Calcul de l'intensité de la lumière en fonction de l'angle
  vertLightIntensity = max(0.0, dot(vertNormal, -vertLightDir));
  
  // Passage des coordonnées de texture au fragment shader
  vertTexCoord = texCoord;
  
  // Passage de la couleur au fragment shader (teinte chaude pour l'extérieur)
  vertColor = color * vec4(1.2, 1.1, 0.8, 1.0);
  
  // Position finale du vertex
  gl_Position = transform * vertex;
}
