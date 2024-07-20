#pragma once
#define enum enum class

enum MapViewerDrawOptions{
    WATER,
    GROUND_TYPE,
    WATER_GROUPS,
    MOISTURE_MAP,
    REGIONS,
    BLUE_NOISE,
    RIVER_DATA,
    LAND_GROUPS,
    EDGE_VALS,
    PLAYER_START_POSITION,
    VISIBLE_REGIONS, //NOTE: Generally only used during gameplay.
    REGION_SEEDS,
    PLACE_LOCATIONS,
    VISIBLE_PLACES_MASK,

    MAX
};

enum MapViewerColours{
    VOXEL_GROUP_GROUND,
    VOXEL_GROUP_GRASS,
    VOXEL_GROUP_ICE,
    VOXEL_GROUP_TREES,
    VOXEL_GROUP_CHERRY_BLOSSOM_TREE,

    OCEAN,
    FRESH_WATER,
    WATER_GROUPS,

    COLOUR_BLACK,
    COLOUR_MAGENTA,
    COLOUR_ORANGE,

    UNDISCOVRED_REGION,

    MAX
};

#undef enum