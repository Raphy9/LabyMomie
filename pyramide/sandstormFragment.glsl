#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform float time;
uniform vec2 resolution;
uniform vec2 windDirection; // Direction du vent (x, y)
uniform float windStrength; // Force du vent
uniform float particleDensity; // Densité des particules

varying vec4 vertColor;
varying vec4 vertTexCoord;

// Fonction de bruit pseudo-aléatoire simplifiée pour optimisation
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Fonction pour générer un grain de sable plus petit et plus rond
float sandGrain(vec2 uv, vec2 center, float size) {
    float dist = length(uv - center);

    // Forme du grain plus ronde avec une transition plus douce
    float grain = smoothstep(size, size * 0.5, dist);

    return grain;
}

void main() {
    // Coordonnées normalisées
    vec2 uv = vertTexCoord.st;

    // Couleur de base (texture originale)
    vec4 baseColor = texture2D(texture, uv);

    // Si la force du vent est trop faible, ne pas appliquer l'effet de tempête
    if (windStrength < 0.3) {
        gl_FragColor = baseColor * vertColor;
        return;
    }

    // Initialisation de la couleur des particules de sable (plus jaune/orangée)
    vec4 sandColor = vec4(0.95, 0.75, 0.35, 1.0); // Couleur sable plus vive et orangée

    // Accumulation des particules de sable
    float sandAccumulation = 0.0;

    // Nombre de particules de sable (réduit pour optimisation)
    int NUM_PARTICLES = int(120.0 * particleDensity);

    // Taille des particules (réduite pour des grains plus petits)
    float particleSize = 0.04 + 0.002 * windStrength;

    // Vitesse de déplacement basée sur la force du vent
    float speed = 0.4 * windStrength;

    // Génération des particules de sable (optimisée)
    for (int i = 0; i < NUM_PARTICLES; i++) {
        // Utiliser un pas plus grand pour réduire le nombre d'itérations
        if (i % 2 != 0) continue;

        // Position de base de la particule (pseudo-aléatoire)
        float randomOffset = float(i) / float(NUM_PARTICLES);
        vec2 pos = vec2(
            random(vec2(randomOffset, time * 0.01)),
            random(vec2(time * 0.02, randomOffset))
        );

        // Ajout du mouvement du vent
        pos += windDirection * speed * time * (0.5 + 0.5 * random(vec2(randomOffset)));

        // Wrap around (boucle) pour que les particules restent à l'écran
        pos = fract(pos);

        // Variation de la taille des particules (simplifiée)
        float sizeVar = 0.5 + 0.5 * random(vec2(randomOffset * 10.0, time * 0.1));

        // Ajout de la particule
        sandAccumulation += sandGrain(uv, pos, particleSize * sizeVar);
    }

    // Limitation de l'accumulation
    sandAccumulation = min(sandAccumulation, 1.5);

    // Effet de brouillard uniforme (sans effet de cercle)
    float dustEffect = random(uv + time * 0.1) * 0.15 * windStrength;

    // Mélange de la couleur de base avec les particules de sable
    vec4 finalColor = mix(baseColor, sandColor, sandAccumulation * 0.7 * windStrength);

    // Ajout de l'effet de brume/poussière uniforme
    finalColor = mix(finalColor, sandColor, min(dustEffect * windStrength, 0.45));

    gl_FragColor = finalColor * vertColor;
}
