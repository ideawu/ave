//  Created by ideawu on 2019/2/27.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "TestAssetView.h"
#import "AssetView.h"

@interface TestAssetView ()
@property AssetView *assetView;
@end

@implementation TestAssetView

- (void)windowDidLoad {
    [super windowDidLoad];
    
	_assetView = [[AssetView alloc] init];
	_assetView.asset = [[VideoAsset alloc] initWidth:800 height:600];
	
	NSArray *files = files = @[
							   @"/Users/ideawu/Downloads/paperplane.svg",
							   @"/Users/ideawu/Downloads/rainbowwing.svg",
							   @"/Users/ideawu/Downloads/imgs/1.jpg",
							   @"/Users/ideawu/Downloads/gif/ha.gif",
							   @"/Users/ideawu/Downloads/imgs/5.jpg",
							   @"/Users/ideawu/Downloads/imgs/9.jpg"
							   ];
	for(NSString *file in files){
		VideoAssetClip *clip = [[VideoAssetClip alloc] init];
		clip.file = file;
		clip.beginTime = _assetView.asset.duration;
		clip.duration = 1.8;
		[_assetView.asset addClip:clip];
	}

	_assetView.viewDuration = _assetView.asset.duration/3;
	_assetView.frame = CGRectMake(0, 0, 500, 100);
	[self.window.contentView addSubview:_assetView];
}

- (void)keyDown:(NSEvent *)event{
	unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
	switch(c){
		case '-':{
			_assetView.viewDuration *= 0.99;
			break;
		}
		case '=':{
			_assetView.viewDuration *= 1.01;
			break;
		}
	}
	[_assetView setNeedsDisplay:YES];
}
@end
