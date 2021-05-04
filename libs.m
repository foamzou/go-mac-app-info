#import "emittedheader.h"

uint8_t * _Nullable getAppInfo(NSInteger pid, NSInteger * _Nonnull size, char * _Nonnull * _Nonnull appInfoJson) {
    return [App GetAppInfoWithPid:pid size:size appInfoJson:appInfoJson];
}
