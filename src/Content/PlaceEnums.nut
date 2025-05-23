
::EnumDef.addToEnum("PlaceId", @"
    GATEWAY,

    GOBLIN_CAMP,
    DUSTMITE_NEST,

    GARRITON,

    TEMPLE,
    GRAVEYARD
");

enum PlaceType{
    NONE,
    GATEWAY,
    CITY,
    TOWN,
    VILLAGE,
    LOCATION,

    MAX
};

//Squirrel doesn't let you shift bits in place :( so this will do fine.
enum PlaceNecessaryFeatures{
    RIVER = 0x1,
    OCEAN = 0x2,
    LAKE = 0x4,
};
