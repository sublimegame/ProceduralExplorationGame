::MainMenuScreen <- class extends ::Screen{

    mWindow_ = null;

    constructor(){

    }

    function setup(){
        mWindow_ = _gui.createWindow();
        mWindow_.setSize(_window.getWidth(), _window.getHeight());
        mWindow_.setVisualsEnabled(false);
        mWindow_.setClipBorders(0, 0, 0, 0);

        local layoutLine = _gui.createLayoutLine();

        local title = mWindow_.createLabel();
        title.setDefaultFontSize(title.getDefaultFontSize() * 2);
        title.setText("Text based game");
        layoutLine.addCell(title);

        local buttonOptions = ["play", "help"];
        local buttonFunctions = [
            function(widget, action){
                ::ScreenManager.transitionToScreen(SaveSelectionScreen());
            },
            function(widget, action){
                print("Help");
            }
        ]

        foreach(i,c in buttonOptions){
            local button = mWindow_.createButton();
            button.setDefaultFontSize(button.getDefaultFontSize() * 1.5);
            button.setText(c);
            button.setSize(_window.getWidth() * 0.9, buttonSize.y);
            button.attachListenerForEvent(buttonFunctions[i], _GUI_ACTION_PRESSED, this);
            layoutLine.addCell(button);
        }

        layoutLine.setMarginForAllCells(0, 20);
        layoutLine.setPosition(_window.getWidth() * 0.05, 100);
        layoutLine.setGridLocationForAllCells(_GRID_LOCATION_CENTER);
        layoutLine.layout();
    }

    function update(){

    }
};