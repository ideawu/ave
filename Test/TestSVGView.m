//  Created by ideawu on 2/20/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "TestSVGView.h"
#import "SVGView.h"

@interface TestSVGView ()<NSWindowDelegate>
@end

@implementation TestSVGView

- (void)windowDidLoad {
    [super windowDidLoad];
	[self.window.contentView setWantsLayer:YES];
	
	NSString *file;
	SVGView *svg = [[SVGView alloc] init];

	file = @"/Users/ideawu/Downloads/imgs/1.jpg";
	[svg loadSVGFile:file size:NSMakeSize(0, 0) offset:NSMakePoint(120, 120) callback:^(SVGViewLoadResult *result) {
		CGFloat w = result.size.width;
		CGFloat h = result.size.height;
		log_debug(@"%f %f", w, h);
		NSImage *img = [svg snapshot];
		self.window.contentView.layer.backgroundColor = [NSColor colorWithPatternImage:img].CGColor;
	}];
	file = @"/Users/ideawu/Downloads/imgs/2.jpg";
	[svg loadSVGFile:file size:NSMakeSize(0, 0) offset:NSMakePoint(120, 120) callback:^(SVGViewLoadResult *result) {
		CGFloat w = result.size.width;
		CGFloat h = result.size.height;
		log_debug(@"%f %f", w, h);
		NSImage *img = [svg snapshot];
		self.window.contentView.layer.backgroundColor = [NSColor colorWithPatternImage:img].CGColor;
		[svg close];
	}];
	
	log_debug(@"");
}

- (void)windowWillClose:(NSNotification *)notification{
	log_debug(@"%s", __func__);
}

@end
