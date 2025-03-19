// Fragment shader pour l'extérieur de la pyramide
// Crée une ambiance claire et ensoleillée

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform float time;

varying vec4 vertColor;
varying vec2 vertTexCoord;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying float vertLightIntensity;

void main() {
  // Échantillonnage de la texture
  vec4 texColor = texture2D(texture, vertTexCoord);
  
  // Calcul de l'éclairage diffus
  float diffuse = max(0.0, dot(vertNormal, -vertLightDir));
  
  // Calcul de l'éclairage spéculaire
  vec3 halfDir = normalize(-vertLightDir + vec3(0.0, 0.0, 1.0));
  float specular = pow(max(0.0, dot(vertNormal, halfDir)), 20.0);
  
  // Calcul de la couleur finale avec une teinte chaude pour l'extérieur
  vec4 ambient = texColor * vertColor * 0.6; // Lumière ambiante forte
  vec4 diffuseColor = texColor * vertColor * diffuse * 0.8;
  vec4 specularColor = vec4(1.0, 0.9, 0.7, 1.0) * specular * 0.5;
  
  // Couleur finale
  vec4 finalColor = (ambient + diffuseColor + specularColor);
  
  // Ajout d'une légère teinte jaune/orange pour simuler la lumière du soleil
  finalColor.r *= 1.1;
  finalColor.g *= 1.05;
  finalColor.b *= 0.9;
  
  gl_FragColor = finalColor;
}
