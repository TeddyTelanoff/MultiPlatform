class Map {
  PImage background;
  Platform[] platforms;

  Map(PImage background, Platform[] platforms) {
    this.background = background;
    this.platforms = platforms;
  }
}

void initMap(String mapId) {
  switch(mapId) {
  case "sky_map":
    backgroundImg = sky_map[0];
    platforms.add(new Platform(300, 700, 400, 50, sky_map[1], Platform.STATIC));
    platforms.add(new Platform(800, 500, 400, 50, sky_map[1], Platform.STATIC));
    platforms.add(new Platform(250, 450, 400, 50, sky_map[1], Platform.STATIC));
    platforms.add(new Platform(650, 300, 400, 50, sky_map[1], Platform.STATIC));
    break;
  case "hell_map":
    backgroundImg = hell_map[0];
    platforms.add(new Platform(300, 500, 500, 50, hell_map[1], Platform.SHAPESHIFTING, 5, 400, 50, 500, 50));
    platforms.add(new Platform(50, 250, 400, 50, hell_map[1], Platform.MOVING, 2.5, 50, 250, 150, 300));
    platforms.add(new Platform(600, 700, 500, 50, hell_map[1], Platform.VANISHING, 10000));
    platforms.add(new Platform(900, 250, 400, 50, hell_map[1], Platform.MOVING, 2.5, 725, 250, 900, 250));
    break;
  case "land_map":
    backgroundImg = land_map[0];
    platforms.add(new Platform(0, 700, 1250, 50, land_map[1], Platform.MOVING, 1, -50, 50, 50, 50));
    break;
  default:
    backgroundImg = land_map[0];
    platforms.add(new Platform(0, 700, 1250, 50, land_map[1], Platform.MOVING, 1, -50, 50, 50, 50));
    break;
  }
}
