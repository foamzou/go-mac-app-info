package go_mac_app_info
/*
#cgo darwin CFLAGS: -DDARWIN -x objective-c -fobjc-arc
#cgo darwin LDFLAGS: -framework Cocoa -framework WebKit

#include <stdlib.h>
#include <libs.h>
*/
import "C"
import (
	"encoding/json"
	"errors"
	"strings"
	"time"
	"unsafe"
)

type AppInfo struct {
	LocalizedName    string `json:"localizedName"`
	ProcessName      string
	launchDate       string `json:"launchDate"`
	LaunchDate       time.Time
	ExecutableURL    string `json:"executableURL"`
	BundleIdentifier string `json:"bundleIdentifier"`
	Icon             []byte
}

func GetInfo(pid int) (AppInfo, error) {
	var appInfo = AppInfo{}
	var size C.size_t
	var appInfoJson *C.char
	bufPointer := C.getAppInfo(C.int(pid), &size, &appInfoJson)

	if bufPointer == nil {
		return AppInfo{}, errors.New("not found")
	}

	jsonStr := C.GoString(appInfoJson)
	_err := json.Unmarshal([]byte(jsonStr), &appInfo)
	if _err != nil {
		return AppInfo{}, _err
	}

	appInfo.ProcessName = parseProcessName(appInfo.ExecutableURL)
	appInfo.ExecutableURL = strings.ReplaceAll(appInfo.ExecutableURL, "%20", " ")

	iconBuf := C.GoBytes(unsafe.Pointer(bufPointer), C.int(size))
	appInfo.Icon = iconBuf

	t, err := time.Parse("2006-01-02T15:04:05.000Z", appInfo.launchDate)
	if err == nil {
		appInfo.LaunchDate = t
	}

	return appInfo, nil
}

func parseProcessName(executableURL string) string {
	splitItem := strings.Split(executableURL, "/")
	name := splitItem[len(splitItem) - 1]
	return strings.ReplaceAll(name, "%20", " ")
}
