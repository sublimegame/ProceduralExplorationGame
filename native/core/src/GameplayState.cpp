#include "GameplayState.h"

#include "MapGen/ExplorationMapDataPrerequisites.h"

namespace ProceduralExplorationGameCore{

   std::vector<bool> GameplayState::mFoundRegions;

    void GameplayState::setNewMapData(ExplorationMapData* mapData){
        size_t regionSize = mapData->regionData.size();
        mFoundRegions.resize(regionSize == 0 ? 1 : regionSize, false);
        std::fill(mFoundRegions.begin(), mFoundRegions.end(), false);
    }

}
