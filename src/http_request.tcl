source ./stdtcl/http.tcl

proc errLog args {
    global LL
    #WriteLog $LL(DEBUG) $args
	puts $args
}

proc SendHttp args {
    global token
    set toUrl [lindex $args 0]
    if {[catch {set token [::http::geturl $toUrl ]} errMsg]} {
        errLog "geturl error: $errMsg"
        return -code -1 "geturl error: $errMsg"
    }
    return "send OK"
}

proc RecvHttp args {
    global token
    ::http::wait $token

    set rStatus [::http::status $token]
    if {$rStatus == "timeout"} {
        errLog "RecvHttp Error: http connect timeout"
        ::http::cleanup $token
        return -code -1 "timeout"
    } elseif {$rStatus == "reset"} {
        errLog "RecvHttp Error: http connect reset"
        ::http::cleanup $token
        return -code -1 "reset"
    } elseif {$rStatus != "ok"} {
        errLog "RecvHttp Error: $rStatus"
        ::http::cleanup $token
        return -code -1 "$rStatus"
    }
    ##############process Responce###################
    set rSize [::http::size $token]
    set rBody [::http::data $token]
    ::http::cleanup $token

    errLog "receive message is [encoding convertfrom utf-8 $rBody]"
    return $rBody
}

proc HttpGet args {
	#set toUrl [lindex $args 0]
    set toUrl "http://google.com"
    puts $toUrl
    if {[catch {SendHttp $toUrl} errMsg]} {
        errLog "SendHttp error: $errMsg"
    } else {
        catch {RecvHttp} respBody
		puts $respBody
    }
}
