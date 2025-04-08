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

// Fonction de bruit pseudo-aléatoire
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Fonction de bruit de Perlin simplifié
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Interpolation cubique
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Quatre coins du carré
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Mélange
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Fonction pour générer un grain de sable
float sandGrain(vec2 uv, vec2 center, float size) {
    float dist = length(uv - center);

    // Forme du grain avec un bord doux
    float grain = smoothstep(size, size * 0.3, dist);

    // Variation de l'opacité en fonction de la distance au centre
    float opacity = grain * (1.0 - dist / size);

    return opacity;
}

void main() {
    // Coordonnées normalisées
    vec2 uv = vertTexCoord.st;

    // Couleur de base (texture originale)
    vec4 baseColor = texture2D(texture, uv);

    // Initialisation de la couleur des particules de sable
    vec4 sandColor = vec4(0.76, 0.70, 0.50, 1.0); // Couleur sable

    // Accumulation des particules de sable
    float sandAccumulation = 0.0;

    // Nombre de particules de sable (ajusté par la densité)
    int NUM_PARTICLES = int(150.0 * particleDensity);

    // Taille des particules (plus grande pour plus de visibilité)
    float particleSize = 0.004 + 0.002 * windStrength;

    // Vitesse de déplacement basée sur la force du vent (augmentée)
    float speed = 0.3 * windStrength;

    // Génération des particules de sable
    for (int i = 0; i < NUM_PARTICLES; i++) {
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

        // Variation de la taille des particules
        float sizeVar = 0.5 + 0.5 * noise(vec2(randomOffset * 10.0, time * 0.1));

        // Ajout de la particule
        sandAccumulation += sandGrain(uv, pos, particleSize * sizeVar);
    }

    // Limitation de l'accumulation
    sandAccumulation = min(sandAccumulation, 1.0);

    // Mélange de la couleur de base avec les particules de sable
    vec4 finalColor = mix(baseColor, sandColor, sandAccumulation * 0.5);

    // Ajout d'un léger effet de flou/brume pour simuler la poussière de sable
    float dustEffect = noise(uv * 3.0 + time * 0.1) * 0.15 * windStrength;
    finalColor = mix(finalColor, sandColor, dustEffect);

    gl_FragColor = finalColor * vertColor;
}
