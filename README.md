# go-mac-app-info
A go module which get information about applications running on macOS

## Quick start
Download module
```shell
go get github.com/foamzou/go-mac-app-info
```
Get app info, example

```go
package main

import (
	"bytes"
	"fmt"
	MacInfo "github.com/foamzou/go-mac-app-info"
	"image"
	"image/png"
	"log"
	"os"
)

func main() {
	info, _ := MacInfo.GetInfo(48197)   // Pass the pid of mac app which is running
	fmt.Println(info.LocalizedName)     // 网易云音乐
	fmt.Println(info.ProcessName)       // NeteaseMusic
	fmt.Println(info.ExecutableURL)     // file:///private/var/folders/z_/1jhr05q92nb0xfn6l8jj0r5c0000gn/T/AppTranslocation/9FB995AD-7879-4275-A9A2-5592C8238632/d/NeteaseMusic.app/Contents/MacOS/NeteaseMusic
	fmt.Println(info.LaunchDate)        // 2021-05-04 22:56:44.948 +0000 UTC
	fmt.Println(info.BundleIdentifier)  // com.netease.163music
	saveImage(info.Icon)                // type of info.Icon is []byte, We can save it to disk or show to UI
}

func saveImage(imgByte []byte) {
	img, _, err := image.Decode(bytes.NewReader(imgByte))
	if err != nil {
		log.Fatalln(err)
	}
	out, _ := os.Create("./img.png")
	defer func(out *os.File) {
		err := out.Close()
		if err != nil {
		}
	}(out)
	err = png.Encode(out, img)

	if err != nil {
		log.Println(err)
	}
}
```

## How to get the info
Use the API of Objective-C: `NSRunningApplication runningApplicationWithProcessIdentifier`

Cgo support call OC code from golang.

There are two branch
- [bridge-swift-via-objectiveC] I try to call swift code through OC bridge
- [directly-swift] I try to call swift without write OC code

I prefer to write swift than OC, so I try to use swift firstly. But I found that the program 
must rely on the dynamic link library(which be created through compile swift code) to run if use swift. 
This will increase the user's cost of use, which is not what I want.

So I have to use OC, pls tell me how can use swift without dll dependence if you have any good trick. Although it sounds unlikely :)