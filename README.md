# 🎮 Nightfall Arena

**Proyecto de videojuego desarrollado en Godot 4**  
Arena Survivor con mecánicas twin-stick shooter, combate dinámico y progresión de enemigos.

---

## 👥 Equipo de Desarrollo

- **Samuel Anacona Narváez**
- **David Medina Trujillo**
- **Steven Moreno Moriano**
- **Nicolás Mueses Muchavisoy**
- **Santiago Romo Ruales**

---

## 🎯 Estado del Parcial: **70% COMPLETO** ✅

### ✅ Core Gameplay Funcional
El juego cuenta con todas las mecánicas fundamentales implementadas y balanceadas.

---

## 📋 Componentes Completados

### 1️⃣ Sistema del Player
- ✅ **Movimiento fluido** en 4 direcciones (WASD / Flechas) - Velocidad: 150
- ✅ **Disparo twin-stick shooter** - Apunta con mouse, mueve con teclado
- ✅ **Sistema de animaciones completo:**
  - `idle` - Estado en reposo
  - `run` / `walk` - Movimiento
  - `attack` - Ataque
  - `receivedamage` - Recepción de daño
  - `death` - Muerte
- ✅ Volteo automático del sprite según dirección
- ✅ Cámara dinámica con zoom 3.5x (vista cercana estilo arena survivor)
- ✅ Sistema de vida: 100 HP con reducción por contacto
- ✅ I-frames (invulnerabilidad temporal de 0.5s)
- ✅ Animación de muerte y Game Over
- ✅ Inmunidad a proyectiles propios
- ✅ Hitbox ajustada manualmente (12x16.6)

### 2️⃣ Sistema de Combate
- ✅ **Disparo automático** hacia cursor del mouse
- ✅ Fire rate: 0.5 segundos (2 disparos/segundo)
- ✅ Proyectiles con gradiente de fuego (amarillo→naranja→rojo)
- ✅ Velocidad de proyectiles: 170.0
- ✅ Daño por proyectil: 15 HP
- ✅ Destrucción al impactar con enemigos
- ✅ Colisión precisa con radius 3.0

### 3️⃣ Sistema de Enemigos Balanceado
**Progresión de dificultad implementada:**

| Enemigo | HP | Daño | Velocidad | Dificultad |
|---------|-----|------|-----------|-----------|
| **EnemyBase** (sin arma) | 25 | 3 | 60 | ⭐ Débil |
| **WhiteSkeleton** (espada) | 40 | 8 | 70 | ⭐⭐ Medio |
| **GoldenSkeleton** (dorado) | 60 | 12 | 80 | ⭐⭐⭐ Fuerte |
| **WarriorBoss** (boss) | 150 | 25 | 50 | ⭐⭐⭐⭐ Boss |

**Características:**
- ✅ IA de persecución al jugador
- ✅ Animaciones completas (idle, walk, attack, hurt, death)
- ✅ Sistema de daño al contacto con player
- ✅ Animación de muerte de 1.5s antes de desaparecer
- ✅ Hitboxes calibradas manualmente
- ✅ Enemigos no se empujan entre sí
- ✅ 4 tipos visuales distintos

### 4️⃣ Mapa y Arena
- ✅ **Tilemap "Really Dark Times"** implementado
- ✅ Arena pintada con tiles de 16x16
- ✅ Diseño de mapa completo
- ✅ Ambiente oscuro temático

### 5️⃣ Sistema de Colisiones Estandarizado
**Capas de colisión optimizadas:**
```
Layer 2 (valor 2):  Player + Hurtbox
Layer 3 (valor 4):  Enemies  
Layer 4 (valor 8):  Projectiles

Player:     layer=2, mask=0 (atraviesa enemigos)
Enemies:    layer=4, mask=2 (solo colisionan con player)
Bullets:    layer=8, mask=4 (solo detectan enemigos)
Hurtbox:    layer=2, mask=4 (detecta enemigos para daño)
```

- ✅ Player puede atravesar enemigos (no empuje)
- ✅ Enemigos se superponen sin empujarse
- ✅ Daño por contacto funcional
- ✅ Proyectiles precisos

### 6️⃣ Spawner de Enemigos
- ✅ Generación dinámica de enemigos
- ✅ Sistema basado en Timer
- ✅ Variedad de tipos instanciados

---

## 🔜 Pendientes (30%)

### UI/HUD
- ❌ Barra de vida visible
- ❌ Contador de kills/score
- ❌ Menú principal
- ❌ Game Over screen con UI
- ❌ Menú de pausa

### Sistemas Avanzados
- ❌ Sistema de XP y niveles
- ❌ Sistema de mejoras/power-ups
- ❌ Sistema de oleadas definidas
- ❌ Sistema de audio (música + SFX)

---

## 🗂️ Estructura del Proyecto

```
nightfall-arena/
├── assets/
│   ├── art/
│   │   ├── player/
│   │   └── enemies/
│   ├── sprites/
│   │   └── fire_bullet.png
│   └── tileset/
│       └── dark_times_tileset.png
│
├── scenes/
│   ├── main_scene.tscn
│   ├── player/
│   │   ├── Player.tscn
│   │   └── player.gd
│   ├── enemies/
│   │   ├── EnemyBase.tscn
│   │   ├── enemy_base.gd
│   │   ├── WhiteSkeleton.tscn
│   │   ├── GoldenSkeleton.tscn
│   │   └── WarriorBoss.tscn
│   ├── projectiles/
│   │   ├── bullet.tscn
│   │   └── bullet.gd
│   └── enemy_spawner.gd
│
└── README.md
```

---

## ⚙️ Mecánicas Implementadas

| Mecánica | Estado | Detalles |
|----------|--------|----------|
| **Movimiento del Player** | ✅ | WASD/Flechas, velocidad 150 |
| **Disparo con Mouse** | ✅ | Twin-stick shooter, auto-fire |
| **Sistema de Proyectiles** | ✅ | Velocidad 170, daño 15 |
| **IA de Enemigos** | ✅ | Persecución inteligente |
| **Progresión de Enemigos** | ✅ | 4 niveles de dificultad |
| **Sistema de Vida** | ✅ | Player 100HP, enemigos 25-150HP |
| **Detección de Daño** | ✅ | Bidireccional player↔enemies |
| **Animaciones** | ✅ | Completas para todos los personajes |
| **Mapa/Arena** | ✅ | Tilemap completo |
| **Balanceo** | ✅ | Stats calibrados |

---

## 🎮 Controles

```
🎯 Movimiento:  WASD o Flechas
🖱️ Apuntar:     Mouse (cursor)
⚡ Disparar:    Automático hacia cursor
```

---

## 🎨 Créditos de Assets

### Player
**[Penzilla Design - Free Animated Protagonist](https://penzilla.itch.io/)**

### Enemigos
- **Skeleton Variants**: [MonoPixelArt - Skeletons Pack](https://monopixelart.itch.io/skeletons-pack)
- **Warrior Boss**: [CreativeKind - Nightborne Warrior](https://creativekind.itch.io/nightborne-warrior)
- **Recursos Adicionales**: [PolishedStone - Animated Pixel Enemies](https://polishedstone.itch.io/animated-pixel-enemies)

### Tilemap
- **Really Dark Times Tileset**: Incluido en assets

---

## 🔧 Especificaciones Técnicas

### Motor
- **Godot 4.x**
- Modo 2D
- Filtro de textura: `Nearest` (pixel art)

### Resolución
- Base: 1152x648
- Escalable

### Balanceo Actual
```
PLAYER:
- HP: 100
- Speed: 150
- Damage: 15 (por bala)
- Fire Rate: 0.5s

ENEMIES:
- EnemyBase:      25HP / 3DMG  / 60SPD
- WhiteSkeleton:  40HP / 8DMG  / 70SPD
- GoldenSkeleton: 60HP / 12DMG / 80SPD
- WarriorBoss:   150HP / 25DMG / 50SPD
```

---

## 🚀 Cómo Ejecutar

1. Abre **Godot 4**
2. Importa el proyecto desde la carpeta `nightfall-arena`
3. Presiona **F5** o el botón **Play** ▶️
4. Usa **WASD** para moverte y **Mouse** para apuntar
5. ¡Sobrevive el mayor tiempo posible!

---

## 📝 Changelog

### Última Actualización: 14/12/2025

**Funcionalidades Nuevas:**
- ✅ Twin-stick shooter (disparo con mouse)
- ✅ Mapa con tileset completo
- ✅ Balanceo completo de 4 enemigos
- ✅ Hitboxes calibradas manualmente
- ✅ Sistema de colisiones optimizado
- ✅ Proyectil visual mejorado (gradiente de fuego)
- ✅ Cámara con zoom apropiado

**Correcciones:**
- ✅ Animaciones de muerte funcionando correctamente
- ✅ Enemigos no se empujan entre sí
- ✅ Player inmune a sus proyectiles
- ✅ Duración de animación de muerte boss (1.5s)

---

## 📄 Licencia

Proyecto académico desarrollado para fines educativos.  
Assets de terceros sujetos a sus respectivas licencias (ver créditos).

---

**Desarrollado con ❤️ en Godot 4**  
**Estado del Parcial: APROBABLE ✅**
