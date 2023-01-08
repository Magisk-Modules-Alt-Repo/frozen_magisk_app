if [ $BOOTMODE = false ]; then
	ui_print "- Installing through TWRP Not supported"
	ui_print "- Intsall this module via Magisk Manager"
	abort "- Aborting installation !!"
fi

MAGISKTMP="$(magisk --path)" || MAGISKTMP=/sbin

[ ! -d "$MAGISKTMP/.magisk/modules/magisk_proc_monitor" ] && {
    MURL=http://github.com/HuskyDG/magisk_proc_monitor
    ui_print "- Process monitor tool is not installed"
    ui_print "  Please install it from $MURL"
    am start -a android.intent.action.VIEW -d "$MURL" &>/dev/null
    abort
}