class BrandingAssetsStructure {
  // Vector Smart City Assets References
  static const String prefix = 'assets/branding/';

  // Branding Images mapping Concept
  static const String logoObsidian = '${prefix}zeus_logo_obsidian.svg';
  static const String mapGridOverlay = '${prefix}map_tactical_grid.png';
  static const String weatherRainIcon = '${prefix}weather_rain_particle.svg';
  static const String smartCityHubConcept = '${prefix}hub_concept.png';

  // Branding Palette Metadata
  static const Map<String, String> designTokens = {
    'primary': '#00E5FF (Neon Cyan)',
    'secondary': '#FFFF007F (Neon Pink)',
    'obsidian': '#07090C (Obsidian Black)',
    'typography': 'Orbitron, Outfit, Google Fonts',
    'theme': 'Dark Cybernetic, Glassmorphism Grid'
  };
}
