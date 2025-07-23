# Pokedex PWA

A Progressive Web App (PWA) built with Vue 3 that displays Pokemon data from the PokeAPI. Browse Pokemon, view detailed stats, and install as a native app on your device.

## Features

### Core Functionality
- 🎮 **Browse Pokemon** - Paginated grid layout with 16 Pokemon per page
- 🃏 **Interactive Pokemon Cards** - Click any Pokemon to view detailed stats, moves, and type information
- 📱 **Fully Responsive** - Optimized for mobile, tablet, and desktop (including 1440p+ displays)
- ⚡ **Fast Loading** - Image preloading and optimized performance

### Search & Discovery  
- 🔍 **Evolution Chain Search** - Search for any Pokemon and see its entire evolution family
- 🏷️ **Type Filtering** - Filter Pokemon by type with beautiful modal interface (18 types available)
- 🔄 **Smart Pagination** - Works seamlessly with both type filtering and evolution search
- 🎯 **Visual Indicators** - Searched Pokemon highlighted with special styling

### User Experience
- 🎨 **Dynamic Type Colors** - Pokemon cards change colors based on their primary type
- 🚀 **Interactive Splash Screen** - Click the spinning pokeball to start the app
- 🖼️ **Full-Screen Modals** - Pokemon cards and type filter open in elegant overlays
- 📲 **PWA Support** - Install as native app on any device

### Technical Features
- 🔄 **Real-time API Integration** - Direct queries to PokeAPI for live data
- 🎭 **Glass-effect UI** - Modern design with backdrop blur effects
- 📊 **Comprehensive Pokemon Data** - HP, height, weight, moves, and evolution chains

## Live Demo

**Live site:** https://pokedex-pwa.up.railway.app/

### Install as PWA
On mobile/tablet devices, you can install this as a native app:
1. Open the live site in your browser
2. Look for the "Install" or "Add to Home Screen" prompt
3. Or manually: Browser menu → "Install Pokedex PWA"

## How to Use

### Getting Started
1. **Launch**: Click the pokeball on the splash screen to enter the app
2. **Browse**: Scroll through Pokemon in the main grid (16 per page)
3. **Navigate**: Use "Previous/Next Page" buttons to explore more Pokemon

### Search Features
- **Pokemon Search**: Type any Pokemon name (e.g., "pikachu") and press Enter
- **Evolution Discovery**: Searching shows the entire evolution family (e.g., search "charmander" to see Charmander → Charmeleon → Charizard)
- **Type Filtering**: Click the hamburger menu (☰) to filter by Pokemon types

### Viewing Pokemon Details
- **Click any Pokemon** to open its detailed card with:
  - HP, height, weight statistics
  - Primary type with matching colors
  - Two random moves with power levels
  - Beautiful type-themed background colors

### Navigation Tips
- **Close cards**: Click the X button or click outside the card
- **Clear searches**: Use the red X button next to search input
- **Reset filters**: Click "Show All Pokemon" or "Clear Filter" buttons

## Development Setup

### Prerequisites
- Node.js 18+ 
- npm or yarn

### Local Development
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

The app runs on `http://localhost:5173` by default.

## Docker Setup

### Using Docker Compose (Recommended)
```bash
# Build and run
docker-compose up -d

# Stop
docker-compose down
```
App will be available at `http://localhost:3001`

### Using Docker directly
```bash
# Build image
docker build -t pokedex-pwa .

# Run container
docker run -p 3001:3000 pokedex-pwa
```

## Tech Stack

- **Framework:** Vue 3 (Composition API)
- **Build Tool:** Vite
- **Styling:** Sass/SCSS with CSS Grid & Flexbox
- **HTTP Client:** Axios
- **API:** PokeAPI via pokeapi-js-wrapper
- **PWA:** Service Worker + Web App Manifest
- **Containerization:** Docker & Docker Compose
- **Deployment:** Optimized for production with serve package

## Project Structure

```
src/
├── App.vue          # Main application component
├── main.js          # Application entry point
public/
├── icons/           # Pokemon type icons
├── manifest.json    # PWA manifest
└── service-worker.js # Service worker for PWA
```

## Recommended IDE Setup

- [VS Code](https://code.visualstudio.com/) + [Vue Language Features](https://marketplace.visualstudio.com/items?itemName=Vue.volar)
