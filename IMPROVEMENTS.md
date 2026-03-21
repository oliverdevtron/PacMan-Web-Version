# PAC-MAN Improvements Specification

## 1. Difficulty Reduction (ALL levels easier)

### EASY Mode (target: playable by a 10-year-old)
- Ghost speed modifier: 0.65 (was 0.85) — much slower ghosts
- Pac-Man speed modifier: 1.10 (was 1.0) — slightly faster Pac-Man
- Frightened time multiplier: 2.5 (was 1.5) — power pellets last much longer
- Elroy multiplier: 0.4 (was 0.7) — Blinky becomes aggressive much later
- Start with 5 lives (was 3)
- Extra life at 5,000 points (was 10,000)
- Ghosts leave house slower: double the dot limits for Inky (60→80) and Clyde (120→160) on level 1
- Ghost AI: Add 15% chance to make suboptimal direction choice (makes ghosts "dumber")
- Collision radius reduced to 0.6*TILE (was 0.8) — more forgiving hitbox

### NORMAL Mode  
- Ghost speed modifier: 0.90 (was 1.0) — slightly easier than strict original
- Frightened time multiplier: 1.3 (was 1.0)
- Start with 4 lives (was 3)
- Extra life at 8,000 points (was 10,000)
- 5% chance for suboptimal ghost direction

### HARD Mode
- Keep as-is, this is authentic difficulty
- Ghost speed modifier: 1.10 (was 1.15)
- Frightened time multiplier: 0.7 (was 0.6)

## 2. New Features

### A. Animated Intro Cutscene
- Before the game starts, show a brief chase animation: Pac-Man running from ghosts across screen, then with power pellet Pac-Man chases ghosts back
- 3-4 seconds, skip with Space

### B. Level Intermission Animations  
- Between levels 2-3, 5-6, 9-10: Show a quick animation (Pac-Man chasing ghost, ghost's sheet gets caught, etc.)
- Brief and fun, 2-3 seconds

### C. Combo Counter / Streak Display
- Show "COMBO x2!", "COMBO x3!" etc. when eating multiple ghosts per power pellet
- Large glowing text with animation

### D. Speed Lines Effect
- When Pac-Man has power pellet active, show motion blur / speed lines behind him
- Screen gets subtle color shift to blue during frightened mode

### E. Ghost Name Tooltips
- When hovering over a ghost on the title screen, show their name & personality
- "BLINKY - The Shadow (Aggressive chaser)"

### F. Stats Screen
- After game over, show detailed stats:
  - Dots eaten, ghosts eaten, fruit collected
  - Time played, max combo, levels completed
  - Show stats in a nice animated reveal

### G. Konami Code Easter Egg
- ↑↑↓↓←→←→BA at title screen
- Activates special mode: Rainbow Pac-Man with trail effects, extra life, fun sound effect
- Show "SECRET MODE ACTIVATED!" text

### H. Speed Run Timer  
- Optional speed timer display (toggle with T key)
- Shows time per level and total time

### I. Screen Flash on Extra Life
- When player gets extra life, flash screen green briefly and show "1UP!" in large text

### J. Ghost Personality Indicators
- Small icons/emotes over ghosts occasionally showing their "mood"
- Blinky: angry face when in Elroy mode
- Clyde: confused face when switching between chase/scatter

## 3. UX Improvements

### A. Better Mobile Support
- Add on-screen D-pad overlay for mobile (4 directional arrows)
- Show touch hint on mobile devices
- Prevent page scroll on mobile while playing

### B. Responsive Title Screen
- Better scaling on mobile
- Ensure buttons are touch-friendly (min 44px)

### C. Keyboard Shortcuts Legend
- Show keyboard shortcuts in pause menu
- P for pause (in addition to Space/ESC)

### D. Visual Level Transition
- Smooth fade-to-black transition between levels
- Show "LEVEL X" in large text with zoom animation

### E. Better Game Over Screen
- Show "NEW HIGH SCORE!" if beaten
- Animated score counting up
- Stats display

### F. Loading Screen
- Brief loading state while fonts load
- Animated Pac-Man eating dots

## 4. Design Improvements

### A. Ghost Colors More Vibrant
- Increase glow on all ghosts
- Add subtle pulsing/breathing animation to ghost bodies

### B. Maze Color Themes
- Different maze color per "world" (every 4 levels):
  - Levels 1-4: Classic blue (#0066ff)
  - Levels 5-8: Purple (#9933ff) 
  - Levels 9-12: Green (#00cc66)
  - Levels 13+: Red/orange (#ff3300)

### C. Background Ambient Particles
- Subtle floating particles in the background for atmosphere
- Small, slow, semi-transparent dots drifting

### D. Score Animation
- Numbers in HUD animate (count up) instead of jumping

## 5. Easter Eggs

### A. Konami Code (described above)
### B. Click the Ghost Eyes  
- Clicking "PAC-MAN" title text 10 times plays a special jingle and ghosts on title screen dance
### C. Level 256 Reference
- If somehow reaching level 256, show a "glitch" effect as homage to the original kill screen
### D. Secret Message
- Pressing "?" during pause shows: "Did you know? The original Pac-Man was designed by Toru Iwatani in 1980!"
