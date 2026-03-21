# PAC-MAN High-End Browser Game Specification

## Overview
A high-end, visually stunning browser-based Pac-Man clone using HTML5 Canvas with all original mechanics faithfully recreated, plus modern visual effects, procedural sound effects, and multiple difficulty levels.

## Core Game Mechanics (Authentic to Original)

### Maze
- 28x31 tile grid (original dimensions)
- Use the original Pac-Man maze layout faithfully
- 240 regular dots (pac-dots, 10 points each)
- 4 power pellets (energizers, 50 points each)
- Ghost house in center with door
- Two side tunnels that wrap around (slow ghosts down in tunnel)
- Maze walls rendered with neon glow effect (not flat colors)

### Pac-Man Movement
- Tile-based movement on a grid
- Arrow keys AND WASD for controls
- Input buffering: player can press direction before reaching intersection, Pac-Man will turn when possible
- Pac-Man stops for 1 frame when eating a dot (authentic)
- Pac-Man can "cut corners" through input buffering (authentic)
- Smooth animated mouth open/close cycle
- Death animation: Pac-Man shrinks/deflates in a spiral

### Ghost AI (4 Ghosts - Authentic Behavior)

Each ghost has unique Chase and Scatter behavior:

**Blinky (Red) - "Shadow":**
- Chase: Directly targets Pac-Man's current tile
- Scatter: Top-right corner
- "Cruise Elroy" mode: When remaining dots fall below threshold, Blinky speeds up
  - Elroy 1: triggered at 20 dots remaining (Level 1), speeds up slightly
  - Elroy 2: triggered at 10 dots remaining (Level 1), speeds up more

**Pinky (Pink) - "Speedy":**
- Chase: Targets 4 tiles AHEAD of Pac-Man's current direction
- When Pac-Man faces UP, target is 4 up AND 4 left (original overflow bug)
- Scatter: Top-left corner

**Inky (Cyan) - "Bashful":**
- Chase: Draw vector from Blinky to a point 2 tiles ahead of Pac-Man, then double that vector. That's Inky's target.
- Scatter: Bottom-right corner

**Clyde (Orange) - "Pokey":**
- Chase: If more than 8 tiles from Pac-Man, targets Pac-Man directly. If within 8 tiles, retreats to scatter corner.
- Scatter: Bottom-left corner

### Ghost Modes (Synchronized)
Scatter/Chase timing per level:
- Level 1: Scatter 7s → Chase 20s → Scatter 7s → Chase 20s → Scatter 5s → Chase 20s → Scatter 5s → Chase ∞
- Level 2-4: Scatter 7s → Chase 20s → Scatter 7s → Chase 20s → Scatter 5s → Chase 1033s → Scatter 1/60s → Chase ∞
- Level 5+: Scatter 5s → Chase 20s → Scatter 5s → Chase 20s → Scatter 5s → Chase 1037s → Scatter 1/60s → Chase ∞

When switching between Scatter↔Chase, ALL ghosts reverse direction immediately.

### Frightened Mode
- Triggered by Power Pellet
- Ghosts turn blue, move slower, choose random direction at intersections
- Pac-Man can eat ghosts: 200 → 400 → 800 → 1600 points (doubles each ghost)
- Duration decreases with level:
  - Level 1: 6s, Level 2: 5s, Level 3: 4s, Level 4: 3s, Level 5: 2s
  - Level 6-8: 5s, Level 9-11: 1s, Level 12-14: 3s, Level 15-16: 1s
  - Level 17+: 0s (ghosts just reverse, no frightened state)
- Ghosts flash white near the end of frightened mode (warning)
- Eaten ghosts: eyes only, move fast back to ghost house, respawn

### Ghost House Rules
- Blinky starts outside
- Pinky, Inky, Clyde start inside ghost house
- Ghosts leave based on dot counter (simplified: Pinky leaves after 0 dots eaten, Inky after 30, Clyde after 60 on Level 1)
- Ghosts bounce up and down inside the house

### Speed System (as fraction of max speed)
| Level | Pac-Man | Pac-Man Fright | Ghost | Ghost Fright | Ghost Tunnel |
|-------|---------|----------------|-------|--------------|-------------|
| 1     | 0.80    | 0.90           | 0.75  | 0.50         | 0.40        |
| 2-4   | 0.90    | 0.95           | 0.85  | 0.55         | 0.45        |
| 5-20  | 1.00    | 1.00           | 0.95  | 0.60         | 0.50        |
| 21+   | 0.90    | --             | 0.95  | --           | 0.50        |

### Scoring
- Pac-Dot: 10 points
- Power Pellet: 50 points
- Ghost eaten: 200, 400, 800, 1600 (per power pellet)
- Bonus Fruit (appears twice per level below ghost house):
  - Level 1: Cherry (100)
  - Level 2: Strawberry (300)
  - Level 3-4: Orange (500)
  - Level 5-6: Apple (700)
  - Level 7-8: Melon (1000)
  - Level 9-10: Galaxian (2000)
  - Level 11-12: Bell (3000)
  - Level 13+: Key (5000)
- Extra life at 10,000 points

### Level Progression
- Level complete when all 240 dots + 4 power pellets eaten
- Brief "level complete" flash animation (maze flashes white/blue)
- Increasing ghost speed and decreasing frightened time
- Support at least 10 distinct levels with progressively harder settings

## Visual Design (High-End / Neon Arcade Aesthetic)

### Color Palette
- Background: Deep black (#0a0a12)
- Maze walls: Neon blue with glow (#0066ff with bloom)
- Pac-Man: Bright yellow (#FFE000) with glow
- Blinky: Red (#FF0000)
- Pinky: Pink (#FFB8FF)
- Inky: Cyan (#00FFFF)
- Clyde: Orange (#FFB852)
- Dots: White/cream with subtle glow
- Power Pellets: Large, pulsing with bright glow
- Frightened ghosts: Blue (#2121FF) flashing to white

### Visual Effects
- Neon glow on maze walls (blur/bloom effect)
- Particle trail behind Pac-Man when moving
- Particle burst when eating dots
- Screen shake when eating a ghost
- Power pellets pulse/breathe animation
- Smooth animations on all entities
- CRT scanline overlay option (subtle)
- Glowing eyes on ghosts
- Score popup numbers float up and fade when eating ghosts/fruit

### HUD
- Score: Top left, large tabular numbers
- High Score: Top center
- Lives: Bottom left (Pac-Man icons)
- Level indicator: Bottom right (fruit icons)
- Current level number display

### Screens
- Title Screen: Use title-bg.png as background, "PAC-MAN" title with neon glow, "Press SPACE to Start", difficulty selection
- Game Over: Score display, high score, "Play Again?"
- Level Complete: Flash animation, brief level transition
- Pause Menu: Semi-transparent overlay, resume/quit options

## Difficulty Levels
- **Easy**: Slower ghosts, longer frightened time, ghosts less aggressive
- **Normal**: Authentic original speeds and timing
- **Hard**: Faster ghosts from the start, shorter frightened time, Elroy mode triggers earlier

## Sound Effects (All Procedural via Web Audio API)
- Waka-waka eating sound (oscillating tone)
- Power pellet eat sound (descending sweep)
- Ghost eaten sound (ascending sweep)
- Death sound (descending chromatic)
- Level complete jingle (ascending arpeggio)
- Siren background (continuous, pitch increases as dots decrease)
- Fruit eat sound (bonus chime)
- Ghost frightened background ambient
- Extra life sound
- Game start intro jingle
- Mute/volume toggle in UI

## Technical Requirements
- Pure HTML5 Canvas (2D context)
- Single HTML file with embedded CSS and JS for simplicity
- 60 FPS game loop with fixed timestep
- No localStorage (sandboxed iframe)
- All assets either generated images (loaded via <img>) or procedural
- Responsive: fills viewport while maintaining aspect ratio
- Keyboard controls: Arrow keys + WASD, Space for start/pause, Escape for pause
- Touch controls: Swipe detection for mobile
- Debug overlay (FPS counter, can be toggled)
- Project path: /home/user/workspace/pacman-game/
- Title background image at: ./assets/title-bg.png

## File Structure
```
pacman-game/
├── index.html       (complete game - HTML + CSS + JS)
├── assets/
│   └── title-bg.png (title screen background)
```
