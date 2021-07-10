#import "TestVideoAsset.h"
#include <a3d/a3d.h>
#include "ave.h"

@interface TestVideoAsset ()
@property (weak) IBOutlet NSView *contentView;
@property (weak) IBOutlet NSTextField *timeLabel;
@property double time;
@property VideoAsset *asset;
@property NSTimer *renderTimer;
@end

@implementation TestVideoAsset

- (IBAction)onTimeScroll:(id)sender {
	NSSlider *slider = (NSSlider *)sender;
	_time = slider.floatValue * 30;
	[self draw];
}

- (void)windowWillClose:(NSNotification *)notification{
	log_debug(@"%s", __func__);
	self.asset = nil;
}

- (void)windowDidLoad {
	[super windowDidLoad];
	[(NSView *)self.contentView setWantsLayer:YES];
	
	int width = 800;
	int height = 600;

	CGRect frame = self.window.frame;
	frame.size.width += width - _contentView.frame.size.width;
	frame.size.height += height - _contentView.frame.size.height;
	[self.window setFrame:frame display:YES animate:NO];

	self.asset = [[VideoAsset alloc] initWidth:width height:height];

	NSArray *files = files = @[
							   @"/Users/ideawu/Downloads/paperplane.svg",
							   @"/Users/ideawu/Downloads/rainbowwing.svg",
//							   @"/Users/ideawu/Downloads/imgs/1.jpg",
//							   @"/Users/ideawu/Downloads/gif/ha.gif",
//							   @"/Users/ideawu/Downloads/imgs/5.jpg",
//							   @"/Users/ideawu/Downloads/imgs/9.jpg"
							   ];
	for(NSString *file in files){
		BOOL isFirst = (file == files.firstObject);
		BOOL isLast = (file == files.lastObject);

		double _transitionDuration = 0.5;
		double _presentDuration = 1;
		
		VideoAssetClip *clip = [[VideoAssetClip alloc] init];
		clip.file = file;
		
		double beginTime = isFirst? 0 : self.asset.duration - _transitionDuration;
		double duration = 2 * _transitionDuration + _presentDuration;
		ave::ViewNode *node = clip.node;
		
		clip.beginTime = beginTime;
		clip.duration = duration;
		
		// transition in
		node->position(0, 0, 0);
		if(isFirst){
			node->opacity(0.5);
		}else{
			node->hide();
		}
		{
			a3d::Animate *action = a3d::Animate::show();
			action->beginTime(beginTime);
			action->duration(_transitionDuration);
			action->disposable(false);
			node->runAnimation(action);
		}
		beginTime += _transitionDuration;
		
		// present
		beginTime += _presentDuration;
		
		// transition out
		if(!isLast){
			a3d::Animate *action = a3d::Animate::hide();
			action->beginTime(beginTime);
			action->duration(_transitionDuration);
			action->disposable(false);
			node->runAnimation(action);
		}
		
		[self.asset addClip:clip];
	}
	
	// add background
	{
		VideoAssetClip *clip = [[VideoAssetClip alloc] init];
		clip.file = @"/Users/ideawu/Downloads/imgs/6.jpg";
		clip.scale = @"fullfill";
		clip.layer = -1;
		clip.beginTime = 0;
		clip.duration = self.asset.duration;
		[self.asset addClip:clip];
	}
	
	[self draw];
	
//	_renderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
//													  target:self
//													selector:@selector(renderTimerCallback)
//													userInfo:nil
//													 repeats:YES];
//	// 为避免 NSButton 等按住的时候卡住 timer，需要将 timer 的 runmode 设为 NSRunLoopCommonModes
//	[[NSRunLoop mainRunLoop] addTimer:_renderTimer forMode:NSRunLoopCommonModes];
}

//- (void)renderTimerCallback{
//	[self draw];
//}

- (void)draw{
	_timeLabel.stringValue = [NSString stringWithFormat:@"%.3f", _time];
	
	[self.asset renderAtTime:_time callback:^{
		log_debug(@"rendered");
		CGImageRef image = self.asset.CGImage;
		NSImage *img = [[NSImage alloc] initWithCGImage:image size:NSMakeSize(self.asset.width, self.asset.height)];
		_contentView.layer.transform = CATransform3DConcat(CATransform3DMakeScale(1, -1, 1), CATransform3DMakeTranslation(0, _contentView.bounds.size.height, 0));
		_contentView.layer.contents = img;
		[_contentView setNeedsDisplay:YES];
	}];
}

- (void)keyDown:(NSEvent *)event{
	unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
	switch(c){
		case 'q':
		case 'Q':{
			[self.window close];
			break;
		}
	}
	
//	[self draw];
}

@end
