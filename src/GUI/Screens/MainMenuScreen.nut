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
        title.setTextHorizontalAlignment(_TEXT_ALIGN_CENTER);
        title.setText("Text based game", false);
        title.sizeToFit(_window.getWidth() * 0.9);
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
            button.attachListenerForEvent(buttonFunctions[i], _GUI_ACTION_PRESSED, this);
            local cellId = layoutLine.addCell(button);
            layoutLine.setCellExpandHorizontal(cellId, true);
            layoutLine.setCellMinSize(cellId, Vec2(0, 100));
        }

        layoutLine.setMarginForAllCells(0, 20);
        layoutLine.setPosition(_window.getWidth() * 0.05, _window.getHeight() * 0.1);
        layoutLine.setGridLocationForAllCells(_GRID_LOCATION_CENTER);
        layoutLine.setSize(_window.getWidth() * 0.9, _window.getHeight());
        layoutLine.layout();
    }

    function update(){

    }
};