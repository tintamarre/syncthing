package main

import "syscall"

var (
	freeConsoleProc, _ = syscall.GetProcAddress(kernel32, "FreeConsole")
)

func freeConsole() error {
	ret, _, callErr := syscall.Syscall(uintptr(freeConsoleProc), 0, 0, 0, 0)
	if ret == 0 {
		return callErr
	}
	return nil
}
