#include "FaceMerger.h"

#include <cassert>
#include <set>

namespace VoxelConverterTool{

    const FaceMerger::FaceIntermediateWrapped FaceMerger::INVALID_FACE_INTERMEDIATE = 0xFFFF;

    const FaceMerger::FaceVec3 FaceMerger::FACES_NORMALS[6] = {
        {0, -1,  0},
        {0,  1,  0},
        {0,  0, -1},
        {0,  0,  1},
        {1,  0,  0},
        {-1, 0,  0},
    };

    const FaceMerger::FaceNormalType FaceMerger::FACE_NORMAL_TYPES[6] = {
        FaceMerger::FaceNormalType::Y,
        FaceMerger::FaceNormalType::Y,
        FaceMerger::FaceNormalType::Z,
        FaceMerger::FaceNormalType::Z,
        FaceMerger::FaceNormalType::X,
        FaceMerger::FaceNormalType::X,
    };

    FaceMerger::FaceMerger(){

    }

    FaceMerger::~FaceMerger(){

    }

    int FaceMerger::getDirectionAForNormalType(FaceNormalType ft) const{
        return 1;
        if(ft == FaceNormalType::Z){
            return 1;
        }
        return FACES_NORMALS[static_cast<size_t>(ft)].x;
    }

    int FaceMerger::getDirectionBForNormalType(FaceNormalType ft) const{
        return 1;
        if(ft == FaceNormalType::Z){
            return 1;
        }
        return FACES_NORMALS[static_cast<size_t>(ft)].y;
    }

    void FaceMerger::commitFaces(VoxelConverterTool::OutputFaces& faces, std::set<uint64>& intermediateFaces, FaceIntermediateContainer& fc, int gridSlice, FaceId f){
        int minA = -1;
        int minB = -1;
        int maxA = -1;
        int maxB = -1;

        bool first = true;
        for(uint64 f : intermediateFaces){
            int aCoord = static_cast<int>(f & 0xFFFF);
            int bCoord = static_cast<int>((f >> 32) & 0xFFFF);

            if(first){
                minA = aCoord;
                minB = bCoord;
                maxA = aCoord + 1;
                maxB = bCoord + 1;
                first = false;
            }else{
                if(aCoord < minA){
                    minA = aCoord;
                }
                if(bCoord < minB){
                    minB = bCoord;
                }
                if(aCoord + 1 > maxA){
                    maxA = aCoord + 1;
                }
                if(bCoord + 1 > maxB){
                    maxB = bCoord + 1;
                }
            }
        }

        WrappedFaceContainer container;
        container.vox = fc.v;
        container.ambientMask = fc.a;
        container.z = gridSlice;
        container.x = minA;
        container.y = minB;
        if(f == 0){
            container.sizeX = maxA - minA;
            container.sizeY = 0;
            container.sizeZ = maxB - minB;
        }
        else if(f == 1){
            container.sizeX = maxA - minA;
            container.sizeY = maxB - minB;
            container.sizeZ = maxB - minB;
        }
        else if(f == 3){
            container.sizeX = maxA - minA;
            container.sizeY = maxB - minB;
            container.sizeZ = 1;
        }else if(f == 2){
            container.sizeX = maxA - minA;
            container.sizeY = maxB - minB;
            container.sizeZ = 0;
        }else{
            container.sizeX = maxA - minA;
            container.sizeY = maxB - minB;
            container.sizeZ = maxB - minB;
        }
        assert(container.sizeX >= 0 && container.sizeY >= 0 && container.sizeZ >= 0);
        container.faceMask = f;
        FaceNormalType ft = FACE_NORMAL_TYPES[f];
        //WrappedFace wf = _wrapFace(container);
        faces.outFaces.push_back(container);
    }

    void FaceMerger::expandFace(int& numFacesMerged, int aCoord, int bCoord, int gridSlice, int aSize, int bSize, FaceId f, FaceIntermediateContainer& fcc, const VoxelConverterTool::OutputFaces& faces, std::vector<FaceIntermediateWrapped>& wrapped, std::set<uint64>& intermediateFaces){

        assert(aCoord >= 0);
        assert(bCoord >= 0);

        const int width = 256;
        const int height = 256;

        uint64 startFace = static_cast<uint64>(aCoord) | static_cast<uint64>(bCoord) << 32;
        size_t startIdx = aCoord + (bCoord * width) + (gridSlice * width * height);
        FaceIntermediateWrapped startFiw = wrapped[startIdx];

        if(startFiw == INVALID_FACE_INTERMEDIATE) return;
        assert(intermediateFaces.find(startFace) == intermediateFaces.end());

        _unwrapFaceIntermediate(startFiw, fcc);

        FaceNormalType ft = FACE_NORMAL_TYPES[f];
        int dirA = getDirectionAForNormalType(ft);
        int dirB = getDirectionBForNormalType(ft);
        assert(dirA != 0 || dirB != 0);

        int maxA = aCoord;
        while(true){
            int nextA = maxA + dirA;
            uint64 checkFace = static_cast<uint64>(nextA) | static_cast<uint64>(bCoord) << 32;
            size_t checkIdx = nextA + (bCoord * width) + (gridSlice * width * height);

            if(nextA < 0 || nextA >= aSize || wrapped[checkIdx] == INVALID_FACE_INTERMEDIATE || intermediateFaces.find(checkFace) != intermediateFaces.end()){
                break;
            }

            FaceIntermediateContainer checkFc;
            _unwrapFaceIntermediate(wrapped[checkIdx], checkFc);

            if(checkFc.a != fcc.a || checkFc.v != fcc.v){
                break;
            }

            maxA = nextA;
        }

        int maxB = bCoord;
        bool canExpandB = true;
        while(canExpandB){
            int nextB = maxB + dirB;

            for(int x = aCoord; x <= maxA; ++x){
                uint64 checkFace = static_cast<uint64>(x) | static_cast<uint64>(nextB) << 32;
                size_t checkIdx = x + (nextB * width) + (gridSlice * width * height);

                if(nextB < 0 || nextB >= bSize || wrapped[checkIdx] == INVALID_FACE_INTERMEDIATE || intermediateFaces.find(checkFace) != intermediateFaces.end()){
                    canExpandB = false;
                    break;
                }

                FaceIntermediateContainer checkFc;
                _unwrapFaceIntermediate(wrapped[checkIdx], checkFc);

                if(checkFc.a != fcc.a || checkFc.v != fcc.v){
                    canExpandB = false;
                    break;
                }
            }

            if(canExpandB){
                maxB = nextB;
            }
        }

        for(int y=bCoord; y <= maxB; ++y){
            for(int x=aCoord; x <= maxA; ++x){
                uint64 mergedFace = static_cast<uint64>(x) | static_cast<uint64>(y) << 32;
                size_t mergedIdx = x + (y * width) + (gridSlice * width * height);

                intermediateFaces.insert(mergedFace);
                wrapped[mergedIdx] = INVALID_FACE_INTERMEDIATE;
                numFacesMerged++;
            }
        }
    }

    void FaceMerger::expand2DGrid(int z, FaceId f, const VoxelConverterTool::OutputFaces& inFaces, std::vector<FaceIntermediateWrapped>& wrapped, VoxelConverterTool::OutputFaces& outFaces){

        //const int width = inFaces.deltaX;
        //const int height = inFaces.deltaZ;
        const int width = 256;
        const int height = 256;

        std::set<uint64> foundFaces;
        for(int y = 0; y < height; y++){
            for(int x = 0; x < width; x++){
                FaceIntermediateContainer fc;
                int numFacesMerged = 0;
                expandFace(numFacesMerged, x, y, z, width, height, f, fc, inFaces, wrapped, foundFaces);
                if(!foundFaces.empty()){
                    commitFaces(outFaces, foundFaces, fc, z, f);
                    foundFaces.clear();
                }
            }
        }

    }

    VoxelConverterTool::OutputFaces FaceMerger::mergeFaces(const VoxelConverterTool::OutputFaces& faces){
        std::vector<FaceIntermediateWrapped> faceBuffer;
        //size_t bufSize = faces.deltaX * faces.deltaY * faces.deltaZ;
        size_t bufSize = 256 * 256 * 256;
        faceBuffer.resize(bufSize, INVALID_FACE_INTERMEDIATE);

        const int width = 256;
        const int height = 256;
        const int depth = 256;

        VoxelConverterTool::OutputFaces outFaces;

        for(FaceId f = 0; f < 6; f++){
            //if(f != 3) continue;
            //if(f < 4) continue;
            if(f != 4) continue;
            FaceNormalType ft = FACE_NORMAL_TYPES[f];

            //Produce an easily searchable data structure containing only the target faces.
            for(const WrappedFaceContainer& fc : faces.outFaces){
                //WrappedFaceContainer fc;
                //_unwrapFace(wf, fc);

                int xx = fc.x;
                int yy = fc.y;
                int zz = fc.z;

                if(fc.faceMask != f) continue;
                FaceIntermediateContainer fic = {fc.vox, fc.ambientMask};
                FaceIntermediateWrapped fi =_wrapFaceIntermediate(fic);
                size_t idx = xx + (yy * width) + (zz * width * height);
                assert(idx < faceBuffer.size());
                faceBuffer[idx] = fi;
            }

            for(int z = 0; z < depth; z++){
                expand2DGrid(z, f, faces, faceBuffer, outFaces);
            }

            for(FaceIntermediateWrapped fiw : faceBuffer){
                assert(fiw == INVALID_FACE_INTERMEDIATE);
            }
        }

        outFaces.deltaX = faces.deltaX;
        outFaces.deltaY = faces.deltaY;
        outFaces.deltaZ = faces.deltaZ;

        outFaces.minX = faces.minX;
        outFaces.minY = faces.minY;
        outFaces.minZ = faces.minZ;

        outFaces.maxX = faces.maxX;
        outFaces.maxY = faces.maxY;
        outFaces.maxZ = faces.maxZ;

        return outFaces;
    }

}
