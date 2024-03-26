::ScreenManager.Screens[Screen.GAMEPLAY_MAIN_MENU_SCREEN] = class extends ::Screen{

    function setup(data){
        mWindow_ = _gui.createWindow();
        mWindow_.setSize(_window.getWidth(), _window.getHeight());
        mWindow_.setVisualsEnabled(false);
        mWindow_.setSkinPack("WindowSkinNoBorder");

        local layoutLine = _gui.createLayoutLine();

        local title = mWindow_.createLabel();
        title.setDefaultFontSize(title.getDefaultFontSize() * 2);
        title.setTextHorizontalAlignment(_TEXT_ALIGN_CENTER);
        title.setText("Main Menu", false);
        title.sizeToFit(_window.getWidth() * 0.9);
        layoutLine.addCell(title);

        local buttonOptions = [
            "Explore",
            "Inventory"
            //"Visit"
        ];
        local buttonFunctions = [
            function(widget, action){
                print("Explore");
                ::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.EXPLORATION_SCREEN, {"logic": ::Base.mExplorationLogic}));
            },
            function(widget, action){
                print("Inventory");
                ::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.INVENTORY_SCREEN, {"stats": ::Base.mPlayerStats, "disableBackground": true}));
            },
            /*
            function(widget, action){
                print("Visit");
                ::ScreenManager.transitionToScreen(::ScreenManager.ScreenData(Screen.VISITED_PLACES_SCREEN, {"stats": ::Base.mPlayerStats}));
            }
            */
        ]

        foreach(i,c in buttonOptions){
            local button = mWindow_.createButton();
            button.setDefaultFontSize(button.getDefaultFontSize() * 1.5);
            button.setText(c);
            button.setSize(_window.getWidth() * 0.9, button.getSize().y * 1.5);
            button.attachListenerForEvent(buttonFunctions[i], _GUI_ACTION_PRESSED, this);
            button.setExpandHorizontal(true);
            button.setMinSize(0, 100);
            layoutLine.addCell(button);
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