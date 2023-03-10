MODDIR="${0%/*}"

# API_VERSION = 1
STAGE="$1" # prepareEnterMntNs or EnterMntNs
PID="$2" # PID of app process
UID="$3" # UID of app process
PROC="$4" # Process name. Example: com.google.android.gms.unstable
USERID="$5" # USER ID of app
# API_VERSION = 2
# Enable ash standalone
# Enviroment variables: MAGISKTMP, API_VERSION
# API_VERSION = 3
STAGE="$1" # prepareEnterMntNs or EnterMntNs or OnSetUID

DBAPK=$(magisk --sqlite "SELECT value FROM strings WHERE key='requester'" 2>/dev/null | cut -d= -f2)

RUN_SCRIPT(){
    if [ "$STAGE" == "prepareEnterMntNs" ]; then
        prepareEnterMntNs
    elif [ "$STAGE" == "EnterMntNs" ]; then
        EnterMntNs
    elif [ "$STAGE" == "OnSetUID" ]; then
        OnSetUID
    fi
}

prepareEnterMntNs(){
    # this function run on app pre-initialize

    KEY="$(cat "$MODDIR/key.txt")"
    is_key=false
    for k in $KEY; do
        if [ "$PROC" == "$k" ]; then
            is_key=true
            break
        fi
    done

    if [ "$PROC" == "$DBAPK" ]; then
    {
        # This will never run because Zygisk does not allow us to run code for Magisk app 
        while [ -d /proc/$PID ]; do
             sleep 1
        done
        pm hide "$DBAPK"
        su 2000 -c "cmd notification post -S bigtext -t 'Frozen Magisk app' 'Tag' 'Magisk app is now hidden'"
    } &
    elif $is_key; then
    (
        pm unhide "$DBAPK"
        su 2000 -c "cmd notification post -S bigtext -t 'Frozen Magisk app' 'Tag' 'Opening Magisk app...'"
        rotation_mode="$(content query --uri content://settings/system --projection name:value --where "name='accelerometer_rotation'")"
        monkey -p "$DBAPK" -c android.intent.category.LAUNCHER 1 -v 500
        su 2000 -c "cmd notification post -S bigtext -t 'Frozen Magisk app' 'Tag' 'Magisk app is opened'"
        content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:"${rotation_mode##*value=}"
        sleep 2
        DYNPID=-1
        # Zygisk does not allow us to run code for Magisk app 😥
        # So we catch Magisk app through key app
        APPPID="$(pidof "$DBAPK")" || exit
        APPUID="$(stat -c "%u" "/data/data/$DBAPK")" || exit
        for pid in $APPPID; do
            if [ "$(stat -c "%u" "/proc/$pid")" == "$APPUID" ]; then
                DYNPID="$pid"
                break
            fi
        done
        while [ -d /proc/$DYNPID ]; do
             sleep 1
        done
        pm hide "$DBAPK"
        su 2000 -c "cmd notification post -S bigtext -t 'Frozen Magisk app' 'Tag' 'Magisk app is now hidden'"
    ) &
    fi

    # call exit 0 to let script to be run in EnterMntNs
    exit 1 # close script
}


EnterMntNs(){
    # this function will be run when mount namespace of app process is unshared
    # call exit 0 to let script to be run in OnSetUID
    exit 1 # close script
}


OnSetUID(){
    # this function will be run when UID is changed from 0 to $UID
    exit 1 # close script
}

RUN_SCRIPT


