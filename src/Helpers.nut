::Vec3_ZERO <- Vec3(0, 0, 0);
::Vec3_UNIT_X <- Vec3(1, 0, 0);
::Vec3_UNIT_Y <- Vec3(0, 1, 0);
::Vec3_UNIT_Z <- Vec3(0, 0, 1);
::Vec3_UNIT_SCALE <- Vec3(1, 1, 1);

::wrapToString <- function(obj, name, desc=null){
    return (desc == null ?
        format("(%s '%s')", typeof obj, name) :
        format("(%s '%s: %s')", typeof obj, name, desc)
    );
}


::determineGitHash <- function(){
    if(getconsttable().rawin("GIT_HASH")){
        return getconsttable().rawget("GIT_HASH");
    }

    //Otherwise try and read it from the git directory.
    local directory = _settings.getDataDirectory();
    local path = directory + "/.git/refs/heads/master";
    if(_system.exists(path)){
        local f = File();
        f.open(path);
        local hash = f.getLine();
        return hash.slice(0, 8);
    }

    return null;
}
::getVersionInfo <- function(){
    local hash = determineGitHash();
    local suffix = VERSION_SUFFIX;
    if(hash != null){
        suffix += ("-" + hash);
    }

    local versionTotal = format("%i.%i.%i-%s", VERSION_MAX, VERSION_MIN, VERSION_PATCH, suffix);
    local engine = _settings.getEngineVersion();
    local engineVersionTotal = format("Engine: %i.%i.%i-%s", engine.major, engine.minor, engine.patch, engine.suffix);

    return {
        "info": versionTotal,
        "engineInfo": engineVersionTotal
    };
}

::printVersionInfos <- function(){
    local infos = getVersionInfo();
    local strings = [];
    strings.append(GAME_TITLE.toupper());
    strings.append(infos.info);
    strings.append(infos.engineInfo);

    local max = 0;
    foreach(i in strings){
        local len = i.len();
        if(len > max){
            max = len;
        }
    }

    local decorator = "";
    local padding = "** ";
    local paddingRight = " **";
    local maxExtent = max + (padding.len() * 2);
    for(local i = 0; i < maxExtent; i++){
        decorator += "*";
    }

    print(decorator);
    foreach(i in strings){
        local starting = padding + i;
        local remainder = maxExtent - starting.len() - padding.len();
        local spaces = "";
        for(local i = 0; i < remainder; i++){
            spaces += " ";
        }
        print(starting + spaces + paddingRight);
    }
    print(decorator);
}