#include <stdint.h>
#include <libs.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NSData* toPng(NSImage * image) {
   CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                            context:nil
                                              hints:nil];
   NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
   [newRep setSize:[image size]];
   return [newRep representationUsingType:NSBitmapImageFileTypePNG properties:nil];
}

char* getAppInfo(int pid, size_t* size, char** appInfoJson) {
    NSRunningApplication *app = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    if (app == nil) {
        return nil;
    }

    // datetime
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *launchDate     =   [dateFormat stringFromDate: app.launchDate];

    // dic
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:app.localizedName forKey:@"localizedName"];
    [dict setValue:launchDate forKey:@"launchDate"];
    [dict setValue:app.bundleIdentifier forKey:@"bundleIdentifier"];
    [dict setValue:app.executableURL.absoluteString forKey:@"executableURL"];

    // json
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    *appInfoJson = (char*)[myString UTF8String];

    // convert icon to png (const uint8_t)
    NSData *pngData = toPng(app.icon);
    *size = pngData.length;
    return (char*)[pngData bytes];
};

