# ####################################################################
# Copyright (c) 2013 Wang Yaofu. All Rights Reserved.
#
# Program Description:
# --------------------------------------------------------------
# Author        Date                 Description
# --------------------------------------------------------------
# Wang Yaofu    2013.12.04           Relase
# xxxx          YYYY.mm.dd           上线
#
# Copyrighted (C) by Wang Yaofu
# ####################################################################
# ########################Configuration Begin#########################

# #返回码
set RET_ERROR 1
set RET_OK    0

source ./stdtcl/xml.tcl

# ####################################################################
# Name: create_xmlparser
# Desc: create the xml parser and configure it.
# ####################################################################
proc create_xmlparser {}  {
    set parser [xml::parser]
    $parser configure -elementstartcommand HandleStart
    $parser configure -elementendcommand HandleEnd
    $parser configure -characterdatacommand HandleText

    return $parser
}

# ####################################################################
# Name: HandleStart
# Desc: handle when element start.
# ####################################################################
proc HandleStart {name attrlist} {
    global XMLData CurTag ComTag ComTagList isComTag chkacct

    if {$name == "BIPs"} {
        set chkacct 1
    }
    set CurTag $name
    if {[lsearch -exact $ComTagList $name] >= 0} {
        set ComTag $name
        set isComTag 1
    }
    if {$isComTag} {
        append XMLData($ComTag) " \{"
    }
}

# ####################################################################
# Name: HandleText
# Desc: handle data when in element.
# ####################################################################
proc HandleText {data} {
    global CurTag XMLData ComTag ComTagList isComTag

    if {[string trim $data] != ""} {
        if {$isComTag} {
            append XMLData($ComTag) $data
        } else {
            set XMLData($CurTag) $data
        }
    }
}

# ####################################################################
# Name: HandleEnd
# Desc: handle when element end.
# ####################################################################
proc HandleEnd {name} {
    global CurTag XMLData ComTag ComTagList isComTag

    if {$isComTag} {
        append XMLData($ComTag) "\}"
    }
    set chkacct   0
    if {$chkacct} {
      if {[lsearch -exact $AcctComTagList $name] >= 0} {
        set isComTag 0
        unset ComTag
      }
    } else {
      if {[lsearch -exact $ComTagList $name] >= 0} {
        set isComTag 0
        unset ComTag
      }
    }
}
# ####################################################################
# Name: parse_pkg_body
# Desc: handle the xml package body.
# ####################################################################
proc parse_pkg_body {body} {
    global parser XMLData ComTag ComTagList isComTag

    set ComTag ""
    set ComTagList ""
    set isComTag 0
    set chkacct  0
    $parser parse $body
}
set parser [create_xmlparser]

# ####################################################################
# Name: XmlParser
# Desc: 解析XML报文
# ####################################################################
proc XmlParser { msg } {
    global XMLData

    if { [info exists XMLData(User-Name)] } {
        unset XMLData
    }
    $::parser reset
    parse_pkg_body $msg
    return $RET_OK
}
# #end of local file.