::ConstHelper <- {};

const TRIGGER = 0;
const DAMAGE = 1;

const PROCEDURAL_WORLD_UNIT_MULTIPLIER = 0.4;
const VISITED_WORLD_UNIT_MULTIPLIER = 0.4;

const EFFECT_WINDOW_CAMERA_Z = 100;

const SCREENS_START_Z = 40;
const POPUPS_START_Z = 60;

enum TargetInterface{
    MOBILE,
    DESKTOP,

    MAX
};

enum Component{
    HEALTH = 0,
    MISC = 1
}

enum WorldTypes{
    WORLD,
    PROCEDURAL_EXPLORATION_WORLD,
    PROCEDURAL_DUNGEON_WORLD,
    VISITED_LOCATION_WORLD,
};


enum ObjectType{
    SCREEN_DATA = "ScreenData",
    POPUP_DATA = "PopupData",
    EFFECT_DATA = "EffectData",
};

enum StatType{
    RESTORATIVE_HEALTH,
    ATTACK,
    DEFENSE,

    MAX
};

enum Event{
    INVENTORY_CONTENTS_CHANGED = 1001,
    MONEY_CHANGED = 1002,
    PLACE_VISITED = 1003,

    DIALOG_SPOKEN = 1004,
    DIALOG_META = 1005,

    STORY_CONTENT_FINISHED = 1006,
    PLAYER_DIED = 1007,

    COMBAT_SPOILS_CHANGE = 1008
    MONEY_ADDED = 1009,
    EXP_ORBS_ADDED = 1010
    SCREEN_CHANGED = 1011,

    PLAYER_HEALTH_CHANGED = 1012,
    PLAYER_TARGET_CHANGE = 1013,

    CURRENT_WORLD_CHANGE = 1014,
    ACTIVE_WORLD_CHANGE = 1015,

    WORLD_PREPARATION_GENERATION_PROGRESS = 1016,
    WORLD_PREPARATION_STATE_CHANGE = 1017,
}

enum FoundObjectType{
    NONE,
    ITEM,
    PLACE
};

enum ItemInfoMode{
    KEEP_SCRAP_EXPLORATION,
    USE,
    KEEP_SCRAP_SPOILS,
};

enum Screen{
    SCREEN,
    MAIN_MENU_SCREEN,
    SAVE_SELECTION_SCREEN,
    GAMEPLAY_MAIN_MENU_SCREEN,
    EXPLORATION_SCREEN,
    COMBAT_SCREEN,
    ITEM_INFO_SCREEN,
    INVENTORY_SCREEN,
    VISITED_PLACES_SCREEN,
    PLACE_INFO_SCREEN,
    STORY_CONTENT_SCREEN,
    DIALOG_SCREEN,
    COMBAT_SPOILS_POPUP_SCREEN,
    TEST_SCREEN,
    WORLD_SCENE_SCREEN
    EXPLORATION_TEST_SCREEN,
    EXPLORATION_END_SCREEN,
    PLAYER_DEATH_SCREEN,
    WORLD_GENERATION_STATUS_SCREEN,

    MAX
};

enum Popup{
    POPUP,
    BOTTOM_OF_SCREEN,
    ENCOUNTER,
    REGION_DISCOVERED,

    MAX
};

enum Effect{
    EFFECT,
    SPREAD_COIN_EFFECT,
    LINEAR_COIN_EFFECT,
    LINEAR_EXP_ORB_EFFECT,
    FOUND_ITEM_EFFECT,
    FOUND_ITEM_IDLE_EFFECT,

    MAX
};

enum EquippedSlotTypes{
    NONE,
    HEAD,
    BODY,
    //TODO this whole equippable slot system could be reduced, as there's some duplication with the other equip system.
    HAND,
    LEFT_HAND,
    RIGHT_HAND,
    LEGS,
    FEET,
    ACCESSORY_1,
    ACCESSORY_2,

    MAX
};

enum CombatOpponentAnims{
    NONE,

    HOPPING,
    DYING
};

enum ExplorationGizmos{
    TARGET_ENEMY,

    MAX
};


//Characters --------
enum CharacterModelType{
    NONE,
    HUMANOID,
    GOBLIN,
    SQUID

    MAX
};
::ConstHelper.CharacterModelTypeToString <- function(e){
    switch(e){
        case CharacterModelType.NONE: return "None";
        case CharacterModelType.HUMANOID: return "Humanoid";
        case CharacterModelType.GOBLIN: return "Goblin";
        case CharacterModelType.SQUID: return "Squid";
        default:{
            assert(false);
        }
    }
}
::ConstHelper.ItemIdToString <- function(e){
    return ::Items[e].getName();
}

enum CharacterModelPartType{
    NONE,

    HEAD,
    BODY,
    LEFT_HAND,
    RIGHT_HAND,
    LEFT_FOOT,
    RIGHT_FOOT,

    MAX
};

enum CharacterModelEquipNodeType{
    NONE,

    LEFT_HAND,
    RIGHT_HAND,

    MAX
};

enum CharacterModelAnimId{
    NONE,

    BASE_LEGS_WALK,
    BASE_ARMS_WALK,
    BASE_ARMS_SWIM,

    REGULAR_SWORD_SWING,
    REGULAR_TWO_HANDED_SWORD_SWING,

    SQUID_WALK,

    MAX
};

enum CharacterModelAnimBaseType{
    UPPER_WALK,
    LOWER_WALK,

    UPPER_SWIM,

    MAX
};
//-------------------