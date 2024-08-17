
function start(){
    _gui.setDefaultFontSize26d6((_gui.getOriginalDefaultFontSize26d6()).tointeger());

    _doFile("res://../VoxToMesh/fpsCamera.nut");
    _doFile("res://../../src/Constants.nut");
    _doFile("res://../../src/Helpers.nut");
    _doFile("res://sceneEditorFramework/SceneEditorBase.nut");
    _doFile("res://../../src/Logic/World/TerrainChunkManager.nut");
    _doFile("res://../../src/Logic/World/TerrainChunkFileHandler.nut");
    _doFile("res://../../src/Util/VoxToMesh.nut");

    _doFile("res://SceneEditor.nut");
    _doFile("res://SceneEditorGUITerrainToolProperties.nut");

    ::Base.setup();
}

function update(){
    ::Base.update();
}

function sceneSafeUpdate(){
    ::Base.sceneSafeUpdate();
}

function end(){

}
