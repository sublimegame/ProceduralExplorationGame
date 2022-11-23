::PlaceInfoScreen <- class extends ::Screen{

    mWindow_ = null;

    mPlaceId_ = Item.NONE;
    mItemSlotIdx_ = 0;

    constructor(place, itemSlotIdx = -1){
        mPlaceId_ = place;
        mItemSlotIdx_ = itemSlotIdx;
    }

    function setup(){
        local placeName = ::Places.placeToName(mPlaceId_);
        local placeDescription = ::Places.placeToDescription(mPlaceId_);

        mWindow_ = _gui.createWindow();
        mWindow_.setSize(_window.getWidth(), _window.getHeight());
        mWindow_.setVisualsEnabled(false);
        mWindow_.setClipBorders(0, 0, 0, 0);

        local layoutLine = _gui.createLayoutLine();

        local title = mWindow_.createLabel();
        title.setDefaultFontSize(title.getDefaultFontSize() * 2);
        title.setTextHorizontalAlignment(_TEXT_ALIGN_CENTER);
        title.setText(placeName, false);
        title.sizeToFit(_window.getWidth() * 0.9);
        title.setExpandHorizontal(true);
        layoutLine.addCell(title);

        local description = mWindow_.createLabel();
        description.setText(placeDescription, false);
        description.sizeToFit(_window.getWidth() * 0.9);
        description.setExpandHorizontal(true);
        layoutLine.addCell(description);

        //Add the buttons to either keep or scrap.
        local buttonOptions = ["Visit", "Back"];
        local buttonFunctions = [
            function(widget, action){
                _event.transmit(Event.PLACE_VISITED, mPlaceId_);
                if(mItemSlotIdx_ >= 0) ::Base.mExplorationLogic.removeFoundItem(mItemSlotIdx_);
                //TODO really this would go to the vising screen.
                ::ScreenManager.transitionToScreen(ExplorationScreen(::Base.mExplorationLogic));
            },
            function(widget, action){
                ::ScreenManager.transitionToScreen(ExplorationScreen(::Base.mExplorationLogic));
            }
        ];
        foreach(i,c in buttonOptions){
            local button = mWindow_.createButton();
            button.setDefaultFontSize(button.getDefaultFontSize() * 1.5);
            button.setText(c);
            button.attachListenerForEvent(buttonFunctions[i], _GUI_ACTION_PRESSED, this);
            button.setExpandHorizontal(true);
            button.setMinSize(0, 100);
            layoutLine.addCell(button);
        }

        layoutLine.setMarginForAllCells(0, 5);
        layoutLine.setPosition(_window.getWidth() * 0.05, 50);
        layoutLine.setSize(_window.getWidth() * 0.9, _window.getHeight() * 0.9);
        layoutLine.layout();
    }
};