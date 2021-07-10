//  Created by ideawu on 06/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface SVGViewLoadResult : NSObject
@property NSString *file;
@property NSSize size;
@property NSPoint offset;
@property void (^callback)(SVGViewLoadResult *result);
@end

// 使用完毕后，需要调用 close 方法释放资源
@interface SVGView : WebView

- (void)loadSVGFile:(NSString *)file callback:(void (^)(SVGViewLoadResult *result))callback;
- (void)loadSVGFile:(NSString *)file size:(NSSize)size offset:(NSPoint)offset callback:(void (^)(SVGViewLoadResult *result))callback;

- (NSImage *)snapshot;
- (void)close;

@end
