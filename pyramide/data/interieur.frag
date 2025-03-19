// Fragment shader pour l'intérieur de la pyramide
// Crée une ambiance sombre et mystérieuse

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
varying vec3 vertEyeDir;
varying float fogFactor;

void main() {
  // Échantillonnage de la texture
  vec4 texColor = texture2D(texture, vertTexCoord);
  
  // Calcul de l'éclairage diffus
  float diffuse = max(0.0, dot(vertNormal, vertLightDir));
  
  // Calcul de l'éclairage spéculaire
  vec3 halfDir = normalize(vertLightDir + vertEyeDir);
  float specular = pow(max(0.0, dot(vertNormal, halfDir)), 10.0);
  
  // Calcul de la couleur finale avec une teinte bleuâtre pour l'intérieur
  vec4 ambient = texColor * vertColor * 0.2; // Lumière ambiante faible
  vec4 diffuseColor = texColor * vertColor * diffuse * 0.7;
  vec4 specularColor = vec4(0.5, 0.5, 0.7, 1.0) * specular * 0.3;
  
  // Ajout d'un effet de torche vacillante
  float flicker = 0.9 + 0.1 * sin(time * 10.0);
  
  // Couleur finale avec brouillard
  vec4 finalColor = (ambient + diffuseColor * flicker + specularColor);
  
  // Couleur du brouillard (noir très sombre)
  vec4 fogColor = vec4(0.02, 0.02, 0.04, 1.0);
  
  // Mélange avec le brouillard
  gl_FragColor = mix(fogColor, finalColor, fogFactor);
}
