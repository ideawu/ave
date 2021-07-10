#import "MP4FileWriter.h"

@interface MP4FileWriter(){
	BOOL _sessionStarted;
	AVAssetWriter* _writer;
	AVAssetWriterInput* _writerInput;
	NSString* _path;
}
@property NSString* path;
@property int width;
@property int height;
@property int bitrate;
// CVPixelBuffer and CGContext share the same memory
@property CVPixelBufferRef pixelBuffer;
@property CMVideoFormatDescriptionRef formatDesc;
@property CGContextRef cgcontext;
@end


@implementation MP4FileWriter

- (void)dealloc{
	if(_formatDesc){
		CFRelease(_formatDesc);
	}
	CGContextRelease(_cgcontext);
	CVPixelBufferRelease(_pixelBuffer);
}

- (id)initWithPath:(NSString*)path width:(int)width height:(int)height{
	self = [self initWithPath:path width:width height:height bitrate:0];
	return self;
}

- (id)initWithPath:(NSString*)path width:(int)width height:(int)height bitrate:(int)bitrate{
	self = [super init];
	self.path = path;
	self.width = width;
	self.height = height;
	self.bitrate = bitrate;
	
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    NSURL* url = [NSURL fileURLWithPath:self.path];
	
    _writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:nil];
	NSMutableDictionary *cs = [[NSMutableDictionary alloc] init];
	if(_bitrate > 0){
		[cs setObject:@(_bitrate) forKey:AVVideoAverageBitRateKey];
	}
#if DEBUG
	[cs setObject:@(20) forKey:AVVideoMaxKeyFrameIntervalKey];
#else
	[cs setObject:@(90) forKey:AVVideoMaxKeyFrameIntervalKey];
#endif
#if !TARGET_OS_MAC
	[cs setObject:@(NO) forKey:AVVideoAllowFrameReorderingKey];
#else
	if (@available(macOS 10.10, *)) {
		[cs setObject:@(NO) forKey:AVVideoAllowFrameReorderingKey];
	} else {
		// Fallback on earlier versions
	}
#endif
	// AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel, // failed OS X 10.10+
	// AVVideoExpectedSourceFrameRateKey: @(30),
	NSDictionary* settings;
	settings = @{
				 AVVideoCodecKey: AVVideoCodecH264,
				 AVVideoWidthKey: @(width),
				 AVVideoHeightKey: @(height),
				 AVVideoCompressionPropertiesKey: cs,
				 };
    _writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _writerInput.expectsMediaDataInRealTime = YES;
    [_writer addInput:_writerInput];
	
	_sessionStarted = NO;
	[_writer startWriting];
	
	return self;
}

- (void)finishWithCompletionHandler:(void (^)(void))handler{
	if(!handler){
		handler = ^(){};
	}
	if (@available(macOS 10.9, *)) {
		[_writer finishWritingWithCompletionHandler: handler];
	} else {
		[_writer finishWriting];
		handler();
	}
}

- (BOOL)encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (CMSampleBufferDataIsReady(sampleBuffer)){
		if(!_sessionStarted){
			_sessionStarted = YES;
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startSessionAtSourceTime:startTime];
        }
        if (_writer.status == AVAssetWriterStatusFailed){
			log_debug(@"writer error: %@", _writer.error.localizedDescription);
            return NO;
        }
        if (_writerInput.readyForMoreMediaData == YES){
            [_writerInput appendSampleBuffer:sampleBuffer];
            return YES;
        }
	}
    return NO;
}

- (BOOL)encodeCGImage:(CGImageRef)image pts:(CMTime)pts duration:(CMTime)duration{
	if(!_pixelBuffer){
		// create CVPixelBuffer
		CVPixelBufferCreate(NULL, _width, _height, kCVPixelFormatType_32BGRA, NULL, &_pixelBuffer);
	}
	if(!_formatDesc){
		// create CMVideoFormatDescription from CVPixelBuffer
		CMVideoFormatDescriptionCreateForImageBuffer(NULL, _pixelBuffer, &_formatDesc);
	}
	if(!_cgcontext){
		// create CGContext from CVPixelBuffer
		CVPixelBufferLockBaseAddress(_pixelBuffer, 0);
		void *data = CVPixelBufferGetBaseAddress(_pixelBuffer);
		CVPixelBufferUnlockBaseAddress(_pixelBuffer, 0);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
		_cgcontext = CGBitmapContextCreate(data, _width, _height, 8, 4*_width, colorSpace, bitmapInfo);
		CGColorSpaceRelease(colorSpace);
		CGContextTranslateCTM(_cgcontext, 0.0, _height);
		CGContextScaleCTM(_cgcontext, 1.0, -1.0);
	}
	
	// draw CGImage to CGContext(so to CVPixelBuffer)
	CGContextDrawImage(_cgcontext, CGRectMake(0, 0, _width, _height), image);
	
	CMSampleTimingInfo timeInfo;
	timeInfo.presentationTimeStamp = pts;
	timeInfo.duration = duration;

	CMSampleBufferRef sampleBuffer = NULL;
	CMSampleBufferCreateForImageBuffer(NULL, _pixelBuffer, YES, NULL, NULL, _formatDesc, &timeInfo, &sampleBuffer);
	
	BOOL ret = [self encodeSampleBuffer:sampleBuffer];
	
	CFRelease(sampleBuffer);
	
	return ret;
}

@end
