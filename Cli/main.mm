//  Created by ideawu on 2/20/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGView.h"
#import <SVGKit/SVGKit.h>

int main(int argc, const char * argv[]) {
	@autoreleasepool {
		NSApplication *app = NSApplication.sharedApplication;

		SVGView *svg = [[SVGView alloc] init];
		NSString *file;
		file = @"/Users/ideawu/Downloads/paperplane.svg";

		[svg loadSVGFile:file callback:^(SVGViewLoadResult *result) {
			CGFloat w = result.size.width;
			CGFloat h = result.size.height;
			log_debug(@"%f %f", w, h);
			NSImage *img = [svg snapshot];
			log_debug(@"%@", img);
		}];

		[app run];
	}
	return 0;
}
