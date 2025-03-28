#pragma once

#include "System/EnginePrerequisites.h"
#include "GamePrerequisites.h"

#include <string>
#include <vector>

namespace ProceduralExplorationGameCore{

    typedef AV::uint8 TilePoint;

    static const TilePoint EMPTY_TILE = 0;

    struct VisitedPlaceMapData{
        AV::uint32 width;
        AV::uint32 height;

        AV::uint32 tilesWidth;
        AV::uint32 tilesHeight;

        std::string mapName;
        std::vector<AV::uint8> altitudeValues;
        std::vector<VoxelId> voxelValues;
        std::vector<DataPointData> dataPointValues;
        std::vector<TilePoint> tileValues;
    };

}