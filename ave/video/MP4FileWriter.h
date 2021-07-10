#import <AVFoundation/AVFoundation.h>

@interface MP4FileWriter : NSObject

@property (readonly) NSString* path;
@property (readonly) int bitrate;

- (id)initWithPath:(NSString*)path width:(int)width height:(int)height;
- (id)initWithPath:(NSString*)path width:(int)width height:(int)height bitrate:(int)bitrate;

- (void)finishWithCompletionHandler:(void (^)(void))handler;
- (BOOL)encodeSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (BOOL)encodeCGImage:(CGImageRef)image pts:(CMTime)pts duration:(CMTime)duration;

@end
