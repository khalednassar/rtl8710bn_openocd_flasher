# Main file for AmebaZ series Cortex-M3 parts
#
# !!!!!!
#

set CHIPNAME rtl8711b
set CHIPSERIES amebaz

transport select swd

# Adapt based on what transport is active.
source [find target/swj-dp.tcl]

if { [info exists CHIPNAME] } {
	set _CHIPNAME $CHIPNAME
} else {
	error "CHIPNAME not set. Please do not include amebaz.cfg directly."
}

if { [info exists CHIPSERIES] } {
	# Validate chip series is supported
	if { $CHIPSERIES != "amebaz" } {
		error "Unsupported chip series specified."
	}
	set _CHIPSERIES $CHIPSERIES
} else {
	error "CHIPSERIES not set. Please do not include amebaz.cfg directly."
}

if { [info exists CPUTAPID] } {
	# Allow user override
	set _CPUTAPID $CPUTAPID
} else {
	# Amebaz use a Cortex M4 core.
	if { $_CHIPSERIES == "amebaz" } {
		set _CPUTAPID 0x2ba01477
	}
}

if { [info exists WORKAREASIZE] } {
       set _WORKAREASIZE $WORKAREASIZE
} else {
       set _WORKAREASIZE 0x800
}

swd newdap $_CHIPNAME cpu -irlen 4 -expected-id $_CPUTAPID

set _TARGETNAME $_CHIPNAME.cpu
dap create $_CHIPNAME.dap -chain-position $_CHIPNAME.cpu

set _ENDIAN little

target create $_TARGETNAME cortex_m -endian $_ENDIAN -dap $_CHIPNAME.dap

$_TARGETNAME configure -work-area-phys 0x10001000 -work-area-size $_WORKAREASIZE -work-area-backup 0

adapter speed 1000
adapter srst delay 200

# AmebaZ (Cortex M4 core) support SYSRESETREQ
if {![using_hla]} {
    # if srst is not fitted use SYSRESETREQ to
    # perform a soft reset
    cortex_m reset_config sysresetreq
}

$_TARGETNAME configure -event reset-init {amebaz_init}
