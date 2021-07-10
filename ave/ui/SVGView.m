//  Created by ideawu on 06/02/2018.
//  Copyright © 2018 ideawu. All rights reserved.
//

#import "SVGView.h"

@implementation SVGViewLoadResult
@end

@interface SVGView()<WebUIDelegate, WebFrameLoadDelegate, WebResourceLoadDelegate, WebPolicyDelegate>
{
}
@property BOOL isClosed;
@property BOOL isReady;
@property NSMutableArray *jobs;
@property SVGViewLoadResult *pending;
@end

@implementation SVGView

- (id)init{
	log_debug(@"%s", __func__);
	self = [super init];
	self.frame = CGRectMake(0, 0, 100, 100);
	self.drawsBackground = NO;
	[self setup];
	return self;
}

- (void)dealloc{
	log_debug(@"%s", __func__);
}

- (void)setup{
	[self setUIDelegate:self];
	[self setFrameLoadDelegate:self];
	[self setResourceLoadDelegate:self];
	[self setPolicyDelegate:self];

	NSURL* fileURL = [NSURL fileURLWithPath:@"file://"];
	[self.mainFrame loadHTMLString:[SVGView html] baseURL:fileURL];

	_jobs = [[NSMutableArray alloc] init];
}

- (void)close{
	if(self.isClosed){
		return;
	}
	self.isClosed = YES;
	self.isReady = NO;

//	log_debug(@"%s", __func__);
	[super close];
	[self setUIDelegate:nil];
	[self setFrameLoadDelegate:nil];
	[self setResourceLoadDelegate:nil];
	[self setPolicyDelegate:nil];
	[self.windowScriptObject setValue:nil forKey:@"external"];
	_jobs = nil;
	_pending = nil;
}

- (NSImage *)snapshot{
	NSView *webFrameViewDocView = self.mainFrame.frameView.documentView;
	NSRect cacheRect = [webFrameViewDocView bounds];
	NSBitmapImageRep *bitmapRep = [webFrameViewDocView bitmapImageRepForCachingDisplayInRect:cacheRect];
	[webFrameViewDocView cacheDisplayInRect:cacheRect toBitmapImageRep:bitmapRep];
	
	NSImage *image = [[NSImage alloc] initWithSize:cacheRect.size];
	[image addRepresentation:bitmapRep];
	return image;
}

- (void)loadSVGFile:(NSString *)file callback:(void (^)(SVGViewLoadResult *result))callback{
	[self loadSVGFile:file size:NSZeroSize offset:NSMakePoint(0, 0) callback:callback];
}

- (void)loadSVGFile:(NSString *)file size:(NSSize)size offset:(NSPoint)offset callback:(void (^)(SVGViewLoadResult *result))callback{
	SVGViewLoadResult *job = [[SVGViewLoadResult alloc] init];
	job.file = file;
	job.size = size;
	job.offset = offset;
	job.callback = callback;
	[_jobs addObject:job];
	
	[self jobConsume];
}

- (void)jobConsume{
	if(!self.isReady){
		return;
	}
	if(_pending){
		return;
	}
	
	if(_jobs.count == 0){
		return;
	}
	SVGViewLoadResult *job = nil;
	job = _jobs.firstObject;
	[_jobs removeObjectAtIndex:0];
	self.pending = job;
	
//	log_debug(@"process job %@", job.file);
	NSString *script = [NSString stringWithFormat:@"loadUrl('%@', %f, %f, %f, %f);",
						job.file, job.size.width, job.size.height, job.offset.x, job.offset.y];
	[self.mainFrame.windowObject evaluateWebScript:script];
}

- (void)jobFinished:(NSArray *)args{
	NSString *file = [args objectAtIndex:0];
	NSNumber *width = [args objectAtIndex:1];
	NSNumber *height = [args objectAtIndex:2];
	log_debug(@"loaded %@, width: %.2f, height: %.2f", file, width.floatValue, height.floatValue);

	SVGViewLoadResult *result = self.pending;
	result.size = CGSizeMake(width.floatValue, height.floatValue);
	self.pending = nil;
	
	// TODO: max size
	CGRect frame = self.frame;
	frame.size = CGSizeMake(width.floatValue, height.floatValue);
	self.frame = frame;
	
	if(result.callback){
		result.callback(result);
	}
	
	[self jobConsume];
}



- (void)webView:(WebView *)webView didClearWindowObject:(WebScriptObject *)script forFrame:(WebFrame *)frame{
//	log_debug(@"%s %@", __func__, script);
	[script setValue:self forKey:@"external"];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
//	log_debug(@"%s", __func__);
	self.isReady = YES;
	[self jobConsume];
}

#pragma mark - 暴露给js的方法

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name{
//	log_debug(@"%@ received %@ for '%s'", self, NSStringFromSelector(_cmd), name);
	return YES;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
//	log_debug(@"%@ received %@ for '%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(selector));
	static NSArray *methods = nil;
	if(methods == nil){
		methods = @[
					NSStringFromSelector(@selector(log:)),
					NSStringFromSelector(@selector(imageLoaded:)),
					];
	}
	if([methods containsObject:NSStringFromSelector(selector)]){
		return NO;
	}
	return YES;
}

+ (NSString *)webScriptNameForSelector:(SEL)sel {
//	log_debug(@"%@ received %@ with sel='%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(sel));
	static NSDictionary *names = nil;
	if(names == nil) {
		names = @{
				  NSStringFromSelector(@selector(log:)): @"log",
				  NSStringFromSelector(@selector(imageLoaded:)): @"imageLoaded",
				  };
	}
	NSString *name = [names objectForKey: NSStringFromSelector(sel)];
	return name;
}

- (void)log:(NSString *)msg{
//	NSLog(@"log by js: %@", msg);
}

- (void)imageLoaded:(NSArray *)args{
	[self jobFinished:args];
}

+ (NSString *)html{
	return @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n	<style>\n	body {\n	  margin: 0px;\n	  padding: 0px;\n	  width: 100vw;\n	  height: 100vh;\n	  background-color: none;\n	}\n	.canvas {\n	  position: relative;\n	  overflow: hidden;\n	  width: 100%;\n	  height: 100%;\n	  /* 自身垂直水平居中 */\n	  margin: auto;\n	  top: 50%;\n	  transform: translateY(-50%);\n	  /* 子元素垂直水平居中 */\n	  display: flex;\n	  justify-content: center;\n	  align-items: center;\n	}\n	</style>\n	\n	<script>\n	var job = {file:'',w:0,h:0,x:0,y:0};\n	var $img = new Image();\n	$img.style.position = 'relative';\n	$img.onload = function() {\n		job.w = job.w | $img.width;\n		job.h = job.h | $img.height;\n		try{\n			external.log('ok ' + job.file);\n			external.imageLoaded([job.file, job.w, job.h]);\n		}catch(e){};\n	}\n	$img.onerror = function() {\n		try{\n			external.log('error ' + job.file);\n			external.imageLoaded([job.file, 0, 0]);\n		}catch(e){};\n	}\n	\n	function loadUrl(url, w, h, x, y){\n		job.file = url;\n		job.w = w | 0;\n		job.h = h | 0;\n		job.x = x | 0;\n		job.y = y | 0;\n		try{\n			external.log(url);\n		}catch(e){};\n		var $canvas = document.querySelectorAll('.canvas')[0];\n		$canvas.innerHTML = '';\n		$canvas.appendChild($img);\n		resize(job.w, job.h);\n		offset(job.x, job.y);\n		$img.src = url;\n	}\n\n	function resize(w, h) {\n		if(w > 0 && h > 0){\n			$img.setAttribute('width', w + 'px');\n			$img.setAttribute('height', h + 'px');\n		}\n	}\n\n	function offset(x, y) {\n		y *= -1;\n		var left =  x + 'px';\n		let top = y + 'px';\n		$img.style.left = left;\n		$img.style.top = top;\n	}\n	</script>\n</head>\n<body>\n\n<div class=\"canvas\">\n</div>\n\n</body>\n</html>\n";
}

@end
