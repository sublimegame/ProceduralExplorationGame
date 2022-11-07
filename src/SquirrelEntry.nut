function start(){
    ::buttonSize <- Vec2(350, 90);

    _camera.setProjectionType(_PT_ORTHOGRAPHIC);
    _camera.setOrthoWindow(40, 40);
    _camera.setPosition(0, 0, 5);
    _camera.lookAt(0, 0, 0);
    _camera.setPosition(1, 15, 5);

    local winSize = Vec2(_window.getWidth(), _window.getHeight())
    _gui.setCanvasSize(winSize, winSize);

    _doFile("res://src/GameStateMenu.nut");
    _doFile("res://src/GameStatePlaying.nut");

    ::currentState <- null;

    //Start the menu off.
    if(_settings.getUserSetting("skipStartupMenu")){
        startState(::GameStatePlaying);
    }else{
        startState(::GameStateMenu);
    }
}

function update(){

}

function end(){

}

::startState <- function(stateClass){
    if(::currentState != null){
        ::currentState.end();
    }
    ::currentState = stateClass();

    ::currentState.start();
}
