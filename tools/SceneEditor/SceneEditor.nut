enum TerrainEditState{
    NONE,
    HEIGHT,
    COLOUR
};

::SceneEditorWindowListener <- class extends ::EditorGUIFramework.WindowManagerListener{
    function resized(id, newSize){
        ::Base.mEditorBase.resizeGUIWindow(id, newSize);
    }

    function closed(id){
        ::Base.mEditorBase.closeGUIWindow(id);
    }
};

::Base <- {

    mEditorBase = null
    mParentNode = null
    mTargetMap = null
    mSceneTree = null

    mKeyCommands = null
    mPrevKeyCommands = null

    mAcceptHandle = null

    mTerrainChunkManager = null
    mTileGridPlacer = null
    mCurrentTileData = null
    mTileSceneNode = null
    mVisitedPlacesMapData = null
    mTileSize = 5

    mEditingTerrain = false
    mEditingTileGrid = false
    mEditingTerrainMode = TerrainEditState.NONE
    mEditTerrainColourValue = 0
    mEditTerrainHeightValue = 0

    mWindowTileGrid_ = null
    mWindowTerrainTool_ = null

    mGuiInputStealerWindow_ = null
    mGuiInputStealer_ = null

    mTerrainEditActive_ = false

    mCurrentHitPosition = Vec3()
    mCurrentHitPositionPlane = Vec3()
    mTestPlane_ = Plane(::Vec3_UNIT_Y, Vec3(0, 0, 0))

    mEditTileData_ = {
        "tile": 1,
        "tileType": 0,
        "tileRotation": 0
    }

    function createLights(){
        //TODO remove the copy and pasting from base.
        //Create lighting upfront so all objects can share it.
        local light = _scene.createLight();
        local lightNode = _scene.getRootSceneNode().createChildSceneNode();
        lightNode.attachObject(light);

        light.setType(_LIGHT_DIRECTIONAL);
        light.setDirection(0, -1, -1);
        //light.setPowerScale(PI * 2);
        light.setPowerScale(PI);
        //light.setPowerScale(PI * 0.8);

        local val = 2.0;
        _scene.setAmbientLight(ColourValue(val, val, val, 1.0), ColourValue(val, val, val, 1.0), ::Vec3_UNIT_Y);
    }

    function setup(){
        mKeyCommands = array(KeyCommand.MAX);
        mPrevKeyCommands = array(KeyCommand.MAX);

        //Custom implementation of helper functions.
        ::SceneEditorFramework.HelperFunctions = {
            function sceneEditorInteractable(){
                //Stub to be implemented by the user.
                return !::guiFrameworkBase.mouseInteracting();
            }
            function sceneTreeConstructObjectForUserEntry(userId, parentNode, entryData){
                switch(userId){
                    case 0:{
                        local item = _gameCore.createVoxMeshItem(entryData.value);

                        item.setRenderQueueGroup(30);
                        item.setQueryFlags(1 << 20);
                        parentNode.attachObject(item);
                        break;
                    }
                    case 1:{
                        break;
                    }
                }
            }
            function getNameForUserEntry(userId){
                switch(userId){
                    case 0:{
                        return "mesh";
                        break;
                    }
                    case 1:{
                        return "userData";
                        break;
                    }
                }
            }
            function raycastForMovementGizmo(){
                return ::Base.castRayForTerrain();
            }
            function basicMouseInteractionEnabled(){
                return !::Base.mEditingTerrain && !::Base.mEditingTileGrid;
            }
        };

        local saveFunction = function(){
            mEditorBase.mBus_.transmitEvent(SceneEditorFramework_BusEvents.REQUEST_SAVE, null);
        }
        local undoFunction = function(){
            mEditorBase.mActionStack_.undo();
        }
        local redoFunction = function(){
            mEditorBase.mActionStack_.redo();
        }
        local positionFunction = function(){
            mEditorBase.getActiveSceneTree().setObjectTransformCoordinateType(SceneEditorFramework_BasicCoordinateType.POSITION);
        }
        local scaleFunction = function(){
            mEditorBase.getActiveSceneTree().setObjectTransformCoordinateType(SceneEditorFramework_BasicCoordinateType.SCALE);
        }
        local sceneQueryFunction = function(){
            mEditorBase.getActiveSceneTree().setObjectTransformCoordinateType(SceneEditorFramework_BasicCoordinateType.RAYCAST);
        }
        ::guiFrameworkBase <- ::EditorGUIFramework.Base();
        ::guiFrameworkBase.setToolbar(::EditorGUIFramework.Toolbar([
            ["File", [
                ["Save", saveFunction.bindenv(this)]
            ]],
            [ "Edit", [
                ["Undo", undoFunction.bindenv(this)],
                ["Redo", redoFunction.bindenv(this)],
                ["Position transform", positionFunction.bindenv(this)],
                ["Scale transform", scaleFunction.bindenv(this)],
                ["Terrain query transform", sceneQueryFunction.bindenv(this)],
            ]]
        ]));
        local windowListener = ::SceneEditorWindowListener();
        ::guiFrameworkBase.attachWindowManagerListener(windowListener);

        ::SceneEditorFPSCamera.start(Vec3(0, 20, 0), Vec3(319.55, -14.55, 0));

        createLights();

        mAcceptHandle = _input.getButtonActionHandle("Accept");
        _input.mapKeyboardInput(_K_SPACE, mAcceptHandle);

        mEditorBase = ::SceneEditorFramework.Base();
        mEditorBase.mBus_.subscribeObject(this);

        mParentNode = _scene.getRootSceneNode().createChildSceneNode();

        local targetMap = getTargetEditMap();
        if(targetMap == null){
            return;
        }
        mTargetMap = targetMap

        mSceneTree = attemptLoadSceneTree(targetMap);
        mEditorBase.setActiveSceneTree(mSceneTree);
        if(mSceneTree != null){
            mSceneTree.debugPrint();
        }

        _gameCore.setMapsDirectory("res://../../assets/maps/");

        _gameCore.beginParseVisitedLocation(targetMap);
        local mapClaim = null;
        while(mapClaim == null){
            mapClaim = _gameCore.checkClaimParsedVisitedLocation();
        }
        mVisitedPlacesMapData = mapClaim;

        mTerrainChunkManager = ::SceneEditorTerrainChunkManager(0);
        mTerrainChunkManager.setup(mapClaim, 4);
        mTerrainChunkManager.generateInitialItems();
        local targetParent = _scene.getRootSceneNode().createChildSceneNode();
        mTerrainChunkManager.setupParentNode(targetParent);

        mTileGridPlacer = ::TileGridPlacer([
            "InteriorFloor.voxMesh", "InteriorWall.voxMesh", "InteriorWallCorner.voxMesh"
        ], mTileSize);
        mCurrentTileData = mVisitedPlacesMapData.getTileArray();
        regenerateTileGrid();

        local winSceneTree = guiFrameworkBase.createWindow(SceneEditorFramework_GUIPanelId.SCENE_TREE, "Scene Tree");
        mEditorBase.setupGUIWindow(SceneEditorFramework_GUIPanelId.SCENE_TREE, winSceneTree.getWin());
        winSceneTree.setPosition(100, 100);
        winSceneTree.setPosition(500, 500);

        local winObjectProperties = guiFrameworkBase.createWindow(SceneEditorFramework_GUIPanelId.OBJECT_PROPERTIES, "Object Properties");
        winObjectProperties.setSize(500, 500);
        winObjectProperties.setPosition(200, 200);
        mEditorBase.setupGUIWindow(SceneEditorFramework_GUIPanelId.OBJECT_PROPERTIES, winObjectProperties.getWin());

        local winTerrainTools = guiFrameworkBase.createWindow(SceneEditorFramework_GUIPanelId.USER_CUSTOM_1, "Terrain Tools");
        winTerrainTools.setSize(500, 500);
        winTerrainTools.setPosition(0, 500);
        mWindowTerrainTool_ = mEditorBase.setupGUIWindowForClass(SceneEditorFramework_GUIPanelId.USER_CUSTOM_1, winTerrainTools.getWin(), ::SceneEditorGUITerrainToolProperties);

        local winTileGrid = guiFrameworkBase.createWindow(SceneEditorFramework_GUIPanelId.USER_CUSTOM_2, "Tile Grid");
        winTileGrid.setSize(500, 500);
        winTileGrid.setPosition(0, 600);
        mWindowTileGrid_ = mEditorBase.setupGUIWindowForClass(SceneEditorFramework_GUIPanelId.USER_CUSTOM_2, winTileGrid.getWin(), ::SceneEditorGUITileGridProperties);

        guiFrameworkBase.loadWindowStates("user://windowState.json");

        mGuiInputStealerWindow_ = _gui.createWindow("guiInputStealer");
        mGuiInputStealerWindow_.setSize(10, 20);
        mGuiInputStealer_ = mGuiInputStealerWindow_.createButton();
        mGuiInputStealer_.setSize(50, 50);
        mGuiInputStealerWindow_.setVisible(false);

        //::posMesh <- _mesh.create("cube");
        //posMesh.setPosition(mCurrentHitPosition);
    }

    function attemptLoadSceneTree(targetMap){
        local targetPath = format("res://../../assets/maps/%s/scene.avscene", targetMap);
        if(!_system.exists(targetPath)){
            return null;
        }
        return mEditorBase.loadSceneTree(mParentNode, targetPath);
    }

    function checkKeyCommands(){
        if(_input.getRawKeyScancodeInput(KeyScancode.LCTRL)){
            if(_input.getRawKeyScancodeInput(KeyScancode.Z)){
                if(_input.getRawKeyScancodeInput(KeyScancode.LSHIFT)){
                    if(setKeyCommand(KeyCommand.REDO)){
                        mEditorBase.mActionStack_.redo();
                    }
                }else{
                    if(setKeyCommand(KeyCommand.UNDO)){
                        mEditorBase.mActionStack_.undo();
                    }
                }
            }
        }

        resetKeyCommands_();
    }

    function resetKeyCommands_(){
        for(local i = 0; i < mKeyCommands.len(); i++){
            mPrevKeyCommands[i] = mKeyCommands[i];
            mKeyCommands[i] = false;
        }
    }

    function setKeyCommand(command){
        if(!mKeyCommands[command]){
            mKeyCommands[command] = true;
            if(!mPrevKeyCommands[command]){
                //The state has just flipped to true so fire the event.
                return true;
            }
        }
        return false;
    }

    function update(){
        checkKeyCommands();
        ::SceneEditorFPSCamera.update();
        //_input.(i, _INPUT_PRESSED)
        ::SceneEditorFPSCamera.setSpeedModifier(_input.getButtonAction(mAcceptHandle));

        //if(mCurrentHitPosition != null){
            //posMesh.setPosition(mCurrentHitPosition);
        //}

        mEditorBase.update();

        ::guiFrameworkBase.update();
        ::guiFrameworkBase.setMousePosition(_input.getMouseX(), _input.getMouseY());
        ::guiFrameworkBase.setMouseButton(0, _input.getMouseButton(_MB_LEFT));
        ::guiFrameworkBase.setMouseButton(1, _input.getMouseButton(_MB_RIGHT));

        if(!::guiFrameworkBase.mouseInteracting() && mEditingTerrain){
            //local mousePos = Vec2(_input.getMouseX(), _input.getMouseY())
            if(::SceneEditorFramework.HelperFunctions.sceneEditorInteractable()){
                //local mTestPlane_ = Plane(::Vec3_UNIT_Y, Vec3(0, 0, 0));
                //mousePos /= _window.getSize();
                //local ray = _camera.getCameraToViewportRay(mousePos.x, mousePos.y);
                //local point = ray.intersects(mTestPlane_);
                local point = mCurrentHitPosition;
                if(point != null){
                    //local worldPoint = ray.getPoint(point);

                    local chunkX = point.x.tointeger();
                    local chunkY = -point.z.tointeger();

                    if(_input.getMouseButton(_MB_LEFT)){
                        if(!mTerrainEditActive_){
                            mTerrainEditActive_ = true;
                            mTerrainChunkManager.notifyActionStart(getTerrainEditState() == TerrainEditState.HEIGHT);
                        }
                        if(getTerrainEditState() == TerrainEditState.HEIGHT){
                            mTerrainChunkManager.drawHeightValues(chunkX, chunkY, 1, 1, [mEditTerrainHeightValue]);
                        }
                        else if(getTerrainEditState() == TerrainEditState.COLOUR){
                            mTerrainChunkManager.drawVoxTypeValues(chunkX, chunkY, 1, 1, [mEditTerrainColourValue]);
                        }
                    }
                }
            }
        }
        if(!::guiFrameworkBase.mouseInteracting() && mEditingTileGrid){
            if(::SceneEditorFramework.HelperFunctions.sceneEditorInteractable()){
                local point = mCurrentHitPositionPlane;
                if(point != null){
                    local chunkX = (point.x / mTileSize).tointeger();
                    local chunkY = (point.z / mTileSize).tointeger();

                    if(_input.getMouseButton(_MB_LEFT)){

                        local v = mEditTileData_.tile;
                        v = v | (mEditTileData_.tileType << 4);
                        setTileToGrid(chunkX, chunkY, v);

                    }
                }
            }
        }
        if(mTerrainEditActive_ && !_input.getMouseButton(_MB_LEFT)){
            mTerrainEditActive_ = false;
            mTerrainChunkManager.notifyActionEnd();
        }
    }

    function shutdown(){
        guiFrameworkBase.serialiseWindowStates("user://windowState.json");
    }

    function setTileToGrid(x, y, val){
        if(x < 0 || y < 0 || x >= mVisitedPlacesMapData.getTilesWidth() || y >= mVisitedPlacesMapData.getTilesHeight()) return;

        local idx = x + y * mVisitedPlacesMapData.getTilesWidth();
        local oldVal = mCurrentTileData[idx];
        if(oldVal == val) return;

        local A = ::SceneEditorFramework.Actions[SceneEditorFramework_Action.USER_1];
        local action = A(this);
        action.populateForCoord(x, y, oldVal, val);
        action.performAction();
        mEditorBase.pushAction(action);

    }

    function setTileToGrid_(x, y, val){
        local idx = x + y * mVisitedPlacesMapData.getTilesWidth();
        mCurrentTileData[idx] = val;
        regenerateTileGrid();
    }

    function regenerateTileGrid(){
        if(mTileSceneNode != null){
            mTileSceneNode.destroyNodeAndChildren();
        }
        mTileSceneNode = _scene.getRootSceneNode().createChildSceneNode();
        if(mCurrentTileData != null){
            mTileGridPlacer.insertGridToScene(mTileSceneNode, mCurrentTileData, mVisitedPlacesMapData.getTilesWidth(), mVisitedPlacesMapData.getTilesHeight());
        }
    }

    function getTargetEditMap(){
        local editMap = _settings.getUserSetting("editMap");
        print(editMap);
        if(editMap != null && typeof editMap == "string"){
            return editMap;
        }
        return null;
    }

    function sceneSafeUpdate(){
        mEditorBase.sceneSafeUpdate();

        mCurrentHitPosition = castRayForTerrain();
        mCurrentHitPositionPlane = castRayForPlane();
    }

    function castRay_(){
        local mousePos = Vec2(_input.getMouseX(), _input.getMouseY());
        local mouseTarget = mousePos / _window.getSize();
        local ray = _camera.getCameraToViewportRay(mouseTarget.x, mouseTarget.y);

        return ray;
    }

    function castRayForTerrain(){
        local ray = castRay_();

        local outPos = mVisitedPlacesMapData.castRayForTerrain(ray);
        return outPos;
    }

    function castRayForPlane(){
        local ray = castRay_();

        local dist = ray.intersects(mTestPlane_);
        if(dist == false) return null;
        local worldPoint = ray.getPoint(dist);
        return worldPoint;
    }

    function notifyFPSBegan(){
        mGuiInputStealer_.setFocus();
    }

    function setEditTerrain(edit){
        mEditingTerrain = edit;
        mEditingTileGrid = false;

        mWindowTerrainTool_.refreshButtons();
        mWindowTileGrid_.refreshButtons();
    }
    function setEditTileGrid(edit){
        mEditingTileGrid = edit;
        mEditingTerrain = false;

        mWindowTerrainTool_.refreshButtons();
        mWindowTileGrid_.refreshButtons();
    }
    function setEditTerrainHeight(edit){
        mEditingTerrainMode = edit ? TerrainEditState.HEIGHT : null;
    }
    function setEditTerrainColour(edit){
        mEditingTerrainMode = edit ? TerrainEditState.COLOUR : null;
    }

    function setEditTerrainColourValue(value){
        mEditTerrainColourValue = value;
    }

    function setEditTerrainHeightValue(height){
        mEditTerrainHeightValue = height;
    }

    function getEditingTerrain(){
        return mEditingTerrain;
    }
    function getEditingTileGrid(){
        return mEditingTileGrid;
    }
    function setEditingTile(tile){
        mEditTileData_.tile = tile;
    }
    function setEditingTileType(tileType){
        mEditTileData_.tileType = tileType;
    }
    function setEditingTileRotation(tileRotation){
        mEditTileData_.tileRotation = tileRotation;
    }

    function getTileEditData(){
        return mEditTileData_;
    }

    function getTerrainEditState(){
        return mEditingTerrainMode;
    }

    function getTerrainEditHeight(){
        return mEditTerrainHeightValue;
    }

    function getTerrainEditColour(){
        return mEditTerrainColourValue;
    }

    function notifyBusEvent(event, data){
        if(event == SceneEditorFramework_BusEvents.REQUEST_SAVE){
            if(mVisitedPlacesMapData.terrainActive()){
                mTerrainChunkManager.performSave(mTargetMap);
            }

            local writer = SceneEditorDataPointWriter();
            writer.performSave(mTargetMap, mSceneTree);
        }
    }

};