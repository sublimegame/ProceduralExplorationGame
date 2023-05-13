::ExplorationCount <- 0;
::ExplorationSceneLogic <- class{

    mParentNode_ = null;
    mWorldData_ = null;
    mVoxMesh_ = null;

    mPlayerNode_ = null;
    mMobScale_ = Vec3(0.2, 0.2, 0.2);

    mActivePlaces_ = null;

    static WORLD_DEPTH = 20;
    ABOVE_GROUND = null;

    mLocationFlagIds_ = 0;
    mLocationFlagNodes_ = null;

    constructor(){
        mLocationFlagNodes_ = {};
    }

    function setup(){
        ABOVE_GROUND = 0xFF - mWorldData_.seaLevel;
        createScene();
        voxeliseMap();

        _world.createWorld();
        _developer.setRenderQueueForMeshGroup(30);

        setupPlaces();
    }

    function setupPlaces(){
        mActivePlaces_ = [];
        foreach(c,i in mWorldData_.placeData){
            local placeEntry = ::ExplorationEntityFactory.constructPlace(i, c);
            mActivePlaces_.append(placeEntry);
        }
    }

    function shutdown(){
        if(mParentNode_) mParentNode_.destroyNodeAndChildren();
        if(mVoxMesh_ == null){
        }

        mParentNode_ = null;
        ::ExplorationEntityFactory.mBaseSceneNode_ = null;

        _world.destroyWorld();
    }

    function resetExploration(worldData){
        shutdown();
        mWorldData_ = worldData;
        setup();
    }

    function voxeliseMap(){
        assert(mWorldData_ != null);
        local width = mWorldData_.width;
        local height = mWorldData_.height;
        local voxData = array(width * height * WORLD_DEPTH, null);
        local buf = mWorldData_.voxelBuffer;
        buf.seek(0);
        local voxVals = [
            2, 112, 0, 192
        ];
        for(local y = 0; y < height; y++){
            for(local x = 0; x < width; x++){
                local vox = buf.readn('i')
                local voxFloat = (vox & 0xFF).tofloat();
                if(voxFloat <= mWorldData_.seaLevel) continue;
                //+1 because vox values at 0 still need to be drawn.
                local altitude = (((voxFloat - mWorldData_.seaLevel) / ABOVE_GROUND) * WORLD_DEPTH).tointeger() + 1;
                local voxelMeta = (vox >> 8) & 0x7F;
                //if(voxFloat <= mWorldData_.seaLevel) voxelMeta = 3;
                for(local i = 0; i < altitude; i++){
                    voxData[x + (y * width) + (i*width*height)] = voxVals[voxelMeta];
                }
            }
        }
        local vox = VoxToMesh(Timer(), 1 << 2);
        //TODO get rid of this with the proper function to destory meshes.
        ::ExplorationCount++;
        local meshObj = vox.createMeshForVoxelData("worldVox" + ::ExplorationCount, voxData, width, height, WORLD_DEPTH);
        mVoxMesh_ = meshObj;

        local item = _scene.createItem(meshObj);
        item.setRenderQueueGroup(30);
        local landNode = mParentNode_.createChildSceneNode();
        landNode.attachObject(item);
        //landNode.setScale(2, 2, 2);
        landNode.setOrientation(Quat(-sqrt(0.5), 0, 0, sqrt(0.5)));

        vox.printStats();
    }

    function getZForPos(pos){
        //Move somewhere else.

        local x = pos.x.tointeger();
        local y = -pos.z.tointeger();

        local buf = mWorldData_.voxelBuffer;
        buf.seek((x + y * mWorldData_.width) * 4);
        local voxFloat = (buf.readn('i') & 0xFF).tofloat();
        local altitude = (((voxFloat - mWorldData_.seaLevel) / ABOVE_GROUND) * WORLD_DEPTH).tointeger() + 1;
        local clampedAltitude = altitude < 0 ? 0 : altitude;

        return clampedAltitude * 0.4;
    }

    function updatePercentage(percentage){
    }

    function createScene(){
        mParentNode_ = _scene.getRootSceneNode().createChildSceneNode();
        ::ExplorationEntityFactory.mBaseSceneNode_ = mParentNode_;

        if(mWorldData_){
            local camera = ::CompositorManager.getCameraForSceneType(CompositorSceneType.EXPLORATION)
            assert(camera != null);
            local parentNode = camera.getParentNode();
            parentNode.setPosition(0, 40, 60);
            camera.lookAt(0, 0, 0);
            //TODO This negative coordinate is incorrect.
            //parentNode.setPosition(mWorldData_.width / 2, 40, -mWorldData_.height / 2);
        }

        //Create the ocean plane
        local oceanNode = mParentNode_.createChildSceneNode();
        local oceanItem = _scene.createItem("plane");
        oceanItem.setRenderQueueGroup(30);
        oceanItem.setDatablock("oceanUnlit");
        oceanNode.attachObject(oceanItem);
        oceanNode.setScale(500, 500, 500)
        oceanNode.setOrientation(Quat(-sqrt(0.5), 0, 0, sqrt(0.5)));

    }

    function updatePlayerPos(playerPos){
        local zPos = getZForPos(playerPos);
        //local zPos = 0;

        local camera = ::CompositorManager.getCameraForSceneType(CompositorSceneType.EXPLORATION)
        assert(camera != null);
        local parentNode = camera.getParentNode();
        parentNode.setPosition(Vec3(playerPos.x, zPos + 10, playerPos.z + 20));
        camera.lookAt(playerPos.x, zPos, playerPos.z);

        //mPlayerNode_.setPosition(Vec3(playerPos.x, zPos, playerPos.y));
    }

    function getFoundPositionForItem(item){
        return Vec3(0, 0, 0);
    }
    function getFoundPositionForEncounter(item){
        return Vec3(0, 0, 0);
    }

    function queueLocationFlag(pos){
        local flagNode = mParentNode_.createChildSceneNode();
        local flagItem = _scene.createItem("locationFlag.mesh");
        flagItem.setRenderQueueGroup(30);
        flagNode.attachObject(flagItem);
        pos.y = getZForPos(pos);
        flagNode.setPosition(pos);
        flagNode.setScale(0.5, 0.5, 0.5);
        local idx = (mLocationFlagIds_++).tostring();
        mLocationFlagNodes_[idx] <- flagNode;
        return idx;
    }
    function removeLocationFlag(idx){
        mLocationFlagNodes_[idx].destroyNodeAndChildren();
        mLocationFlagNodes_[idx] = null;
    }

};