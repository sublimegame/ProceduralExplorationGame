/**
 * Map gen steps which are performed on the script side rather than forced into c++.
 */
::ScriptedMapGen <- class{

    mMapData_ = null;
    mNativeMapData_ = null;
    mReturnPlaces_ = null;
    mPlacesCollisionWorld_ = null;

    constructor(mapData, nativeMapData){
        mMapData_ = mapData;
        mNativeMapData_ = nativeMapData;
    }

    function placeGateway(){
        local point = mMapData_.gatewayPosition;
        local region = ::MapGenHelpers.getRegionForPoint(mNativeMapData_, point);

        local placeData = {
            "originX": (point >> 16) & 0xFFFF,
            "originY": point & 0xFFFF,
            "originWrapped": point,
            "placeId": PlaceId.GATEWAY,
            "region": region
        };

        mReturnPlaces_.append(placeData);
    }

    function _determineRegionBySize(){
        local targetRegions = [];
        foreach(i in mMapData_.regionData){
            if(i.total >= 100 && i.total <= 1500){
                if(i.type == 0){
                    targetRegions.append(i);
                }
            }
        }
        return targetRegions;
    }

    function _determineRegionByType(){
        local targetRegions = [];
        foreach(i in mMapData_.regionData){
            if(i.type == RegionType.DESERT){
                targetRegions.append(i);
            }
        }
        return targetRegions;
    }

    function placeLocation(placeId, determineRegionFunction){
        local targetRegions = determineRegionFunction();
        if(targetRegions.len() == 0) return;

        for(local i = 0; i < 100; i++){
            local targetIdx = mNativeMapData_.randomIntMinMax(0, targetRegions.len()-1);
            local region = targetRegions[targetIdx];

            local point = ::MapGenHelpers.seedFindRandomPointInRegion(mNativeMapData_, region);
            if(point == INVALID_WORLD_POINT) continue;

            local originX = (point >> 16) & 0xFFFF;
            local originY = point & 0xFFFF;
            local RADIUS = 50;
            if(mPlacesCollisionWorld_.checkCollisionPoint(originX, originY, RADIUS)) continue;

            mPlacesCollisionWorld_.addCollisionPoint(originX, originY, RADIUS);

            local placeData = {
                "originX": originX,
                "originY": originY,
                "originWrapped": point,
                "placeId": placeId,
                "region": region.id
            };

            mReturnPlaces_.append(placeData);
            return;
        }
    }

    function determinePlaces(){
        mReturnPlaces_ = [];
        mPlacesCollisionWorld_ = CollisionWorld(_COLLISION_WORLD_BRUTE_FORCE);

        placeGateway();
        placeLocation(PlaceId.GOBLIN_CAMP, _determineRegionBySize);
        placeLocation(PlaceId.GOBLIN_CAMP, _determineRegionBySize);
        placeLocation(PlaceId.GOBLIN_CAMP, _determineRegionBySize);
        placeLocation(PlaceId.GOBLIN_CAMP, _determineRegionBySize);
        placeLocation(PlaceId.GARRITON, _determineRegionBySize);
        placeLocation(PlaceId.TEMPLE, _determineRegionBySize);
        placeLocation(PlaceId.DUSTMITE_NEST, _determineRegionByType);

        local retPlaces = mReturnPlaces_;
        mReturnPlaces_ = null;

        return retPlaces;
    }
}
