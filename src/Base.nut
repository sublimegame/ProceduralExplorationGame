::Base <- {
    "mExplorationLogic": null,
    "mCombatLogic": null,

    //TODO this will be created on encounter in the future.
    "mCurrentCombatData": null,

    "mInventory": null,
    "mPlayerStats": null,
    "mDialogManager": null,
    mInputManager = null

    mCurrentWorld_ = null

    mTargetInterface_ = TargetInterface.DESKTOP

    function checkUserParams(){
        //TODO work around the fact that I can't use multiple avSetup files to override this yet.
        if(_settings.getPlatform() == _PLATFORM_IOS){
            mTargetInterface_ = TargetInterface.MOBILE;
        }
    }
    function getTargetInterface(){
        return mTargetInterface_;
    }

    function setup(){
        checkUserParams();

        //TODO move this somewhere else.
        _animation.loadAnimationFile("res://build/assets/animation/baseAnimation.xml");

        createLights();

        _gui.loadSkins("res://assets/skins/ui.json");

        _doFile("res://src/Helpers.nut");
        _doFile("res://src/System/InputManager.nut");
        _doFile("res://src/Util/VoxToMesh.nut");

        _doFile("res://src/Content/Items.nut");
        _doFile("res://src/Content/Places.nut");
        _doFile("res://src/Content/FoundObject.nut");
        _doFile("res://src/Content/CombatData.nut");
        _doFile("res://src/Content/Projectiles.nut");
        _doFile("res://src/Content/Moves.nut");

        _doFile("res://src/World/EntityFactory.nut");
        _doFile("res://src/World/World.nut");

        _doFile("res://src/Character/CharacterModel.nut");
        _doFile("res://src/Character/CharacterGenerator.nut");
        _doFile("res://src/Character/CharacterModelTypes.nut");

        _doFile("res://src/System/DialogManager.nut");
        mDialogManager = DialogManager();

        _doFile("res://src/System/Inventory.nut");
        mInventory = ::Inventory();

        _doFile("res://src/System/PlayerStats.nut");
        mPlayerStats = ::PlayerStats();

        _doFile("res://src/MapGen/Viewer/MapViewer.nut");
        _doFile("res://src/MapGen/Generator/MapGen.nut");

        ::GuiWidgets <- {};
        _doFile("res://src/GUI/Widgets/InventoryBaseCounter.nut");
        _doFile("res://src/GUI/Widgets/InventoryMoneyCounter.nut");
        _doFile("res://src/GUI/Widgets/InventoryEXPCounter.nut");
        _doFile("res://src/GUI/Widgets/ProgressBar.nut");

        _doFile("res://src/GUI/Billboard/BillboardManager.nut");

        _doFile("res://src/GUI/PopupManager.nut");
        _doFile("res://src/GUI/Popups/Popup.nut");
        _doFile("res://src/GUI/Popups/BottomOfScreenPopup.nut");
        ::PopupManager.setup();

        _doFile("res://src/GUI/EffectManager.nut");
        _doFile("res://src/GUI/Effects/Effect.nut");
        _doFile("res://src/GUI/Effects/SpreadCoinEffect.nut");
        _doFile("res://src/GUI/Effects/LinearCoinEffect.nut");
        _doFile("res://src/GUI/Effects/LinearEXPOrbEffect.nut");
        _doFile("res://src/GUI/Effects/FoundItemEffect.nut");
        _doFile("res://src/GUI/Effects/FoundItemEffectIdle.nut");
        ::EffectManager.setup();

        _doFile("res://src/GUI/ScreenManager.nut");
        _doFile("res://src/GUI/EffectAnimationRenderWindow.nut");
        ::ScreenManager.setup();
        _doFile("res://src/GUI/Screens/Screen.nut");
        _doFile("res://src/GUI/Screens/MainMenuScreen.nut");
        _doFile("res://src/GUI/Screens/SaveSelectionScreen.nut");
        _doFile("res://src/GUI/Screens/GameplayMainMenuScreen.nut");
        _doFile("res://src/GUI/Screens/Exploration/ExplorationScreen.nut");
        _doFile("res://src/GUI/Screens/EncounterPopupScreen.nut");
        _doFile("res://src/GUI/Screens/Combat/CombatScreen.nut");
        _doFile("res://src/GUI/Screens/ItemInfoScreen.nut");
        _doFile("res://src/GUI/Screens/InventoryScreen.nut");
        _doFile("res://src/GUI/Screens/VisitedPlacesScreen.nut");
        _doFile("res://src/GUI/Screens/PlaceInfoScreen.nut");
        _doFile("res://src/GUI/Screens/StoryContentScreen.nut");
        _doFile("res://src/GUI/Screens/DialogScreen.nut");
        _doFile("res://src/GUI/Screens/CombatSpoilsPopupScreen.nut");
        _doFile("res://src/GUI/Screens/TestScreen.nut");
        _doFile("res://src/GUI/Screens/ExplorationTestScreen.nut");
        _doFile("res://src/GUI/Screens/WorldSceneScreen.nut");

        _doFile("res://src/Logic/ExplorationLogic.nut");
        _doFile("res://src/Logic/Scene/ExplorationSceneLogic.nut");
        _doFile("res://src/Logic/ExplorationProjectileManager.nut");
        _doFile("res://src/Logic/Scene/ExplorationEntityFactory.nut");
        _doFile("res://src/Logic/CombatLogic.nut");
        _doFile("res://src/Logic/Scene/CombatSceneLogic.nut");
        _doFile("res://src/Logic/StoryContentLogic.nut");

        _doFile("res://src/GUI/RenderIconManager.nut");
        ::RenderIconManager.setup();

        ::InputManager.setup();

        mExplorationLogic = ExplorationLogic();
        local enemyData = [
            ::Combat.CombatStats(Enemy.GOBLIN, 20),
            ::Combat.CombatStats(Enemy.GOBLIN)
        ];
        mCurrentCombatData = ::Combat.CombatData(mPlayerStats.mPlayerCombatStats, enemyData);
        //TODO temporary to setup the logic. Really a new combatData would be pushed at the start of a new combat.
        mCombatLogic = CombatLogic(mCurrentCombatData);

        //::ScreenManager.transitionToScreen(Screen.MAIN_MENU_SCREEN);
        ::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.EXPLORATION_SCREEN, {"logic": mExplorationLogic}));
        //::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.COMBAT_SCREEN, {"logic": mCombatLogic}));
        //::ScreenManager.transitionToScreen(Screen.TEST_SCREEN);
        //::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.EXPLORATION_TEST_SCREEN, {"logic": mExplorationLogic}));
        //::ScreenManager.transitionToScreen(Screen.WORLD_SCENE_SCREEN);
        //::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.ENCOUNTER_POPUP_SCREEN, null), null, 1);
        //::ScreenManager.transitionToScreen(Screen.ITEM_INFO_SCREEN);
        //::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.INVENTORY_SCREEN, {"inventory": mInventory, "equipStats": ::Base.mPlayerStats.mPlayerCombatStats.mEquippedItems}));
        //::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.VISITED_PLACES_SCREEN, {"stats": mPlayerStats}));
        //::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.PLACE_INFO_SCREEN, {"logic": ::StoryContentLogic(PlaceId.HAUNTED_WELL)}));
        //::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.STORY_CONTENT_SCREEN, {"logic": ::StoryContentLogic(PlaceId.HAUNTED_WELL)}));
        //::ScreenManager.transitionToScreen(Screen.STORY_CONTENT_SCREEN);
        //::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.EXPLORATION_END_SCREEN, {"totalFoundItems": 5, "totalDiscoveredPlaces": 4, "totalEncountered": 2, "totalDefeated": 1}), null, 1);

        setupBaseMeshes();
    }

    function update(){
        ::ScreenManager.update();
        ::PopupManager.update();
        ::EffectManager.update();
        if(mCurrentWorld_) mCurrentWorld_.update();
    }
    function sceneSafeUpdate(){
        if(mCurrentWorld_) mCurrentWorld_.sceneSafeUpdate();
    }

    function notifyEncounter(combatData){
        mCurrentCombatData = combatData;
        mCombatLogic = ::CombatLogic(combatData);
    }

    function notifyEncounterEnded(){
        mCombatLogic.shutdown();
    }

    function createLights(){
        //Create lighting upfront so all objects can share it.
        local light = _scene.createLight();
        local lightNode = _scene.getRootSceneNode().createChildSceneNode();
        lightNode.attachObject(light);

        light.setType(_LIGHT_DIRECTIONAL);
        light.setDirection(-1, -1, -1);
        light.setPowerScale(PI);

        _scene.setAmbientLight(0xffffffff, 0xffffffff, Vec3(0, 1, 0));
    }

    function setupWorld(mapName){
        mCurrentWorld_ = World(mapName);
        mCurrentWorld_.setup();
    }

    function shutdownWorld(){
        if(mCurrentWorld_ == null) return;
        mCurrentWorld_.shutdown();
        mCurrentWorld_ = null;
    }

    function setupBaseMeshes(){
        local voxMesh = VoxToMesh();

        local voxData = array(1, 188);

        local meshObj = voxMesh.createMeshForVoxelData("EXPOrbMesh", voxData, 1, 1, 1);
    }

};
