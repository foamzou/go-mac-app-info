import Quartz

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}
func getInfo(pid: Int, info: inout String) -> Data? {
    let app = NSRunningApplication(processIdentifier: pid_t(pid))
    if app == nil {
        return nil
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    let launchDate = dateFormatter.string(from: app!.launchDate!)

    let dic = ["localizedName":app?.localizedName!, "launchDate": launchDate, "bundleIdentifier": app?.bundleIdentifier!,
        "executableURL": app?.executableURL!.absoluteString
    ]
    let encoder = JSONEncoder()
    if let jsonData = try? encoder.encode(dic) {
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            info = jsonString
        }
    }

    return app?.icon?.png
}

public class App : NSObject {
    @objc public static func GetAppInfo(pid: Int, size: UnsafeMutablePointer<Int>, appInfoJson: UnsafeMutablePointer<UnsafeMutablePointer<CChar>>) -> UnsafeMutablePointer<UInt8>? {
        var appInfo = ""
        var data = getInfo(pid: pid, info: &appInfo)
        if data == nil {
            return nil
        }
        size.pointee = data!.count
        let rawPtr: UnsafeMutablePointer<UInt8> = data!.withUnsafeMutableBytes { (bytePtr: UnsafeMutablePointer<UInt8>) in bytePtr }

        appInfoJson.pointee = strdup(appInfo)

        return rawPtr
    }
}