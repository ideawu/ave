//  Created by ideawu on 3/5/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "TestTimelineEditor.h"
#include "a3d/a3d.h"
#import "ListView.h"
#import "ClipView.h"
#import "TransitionView.h"
#import "TimelineView.h"
#import "Asset.h"

@interface TestTimelineEditor ()<NSWindowDelegate>

@property (weak) IBOutlet NSView *previewArea;
@property (weak) IBOutlet NSView *timelineArea;

@property (weak) IBOutlet NSTextField *timeLabel;

@property double lastRenderTime;
@property TimelineView *timelineView;

@property Asset *asset;
@end

@implementation TestTimelineEditor

- (void)windowWillClose:(NSNotification *)notification {
	log_debug(@"%s", __func__);
	[_timelineView removeFromSuperview];
	_timelineView = nil;
	_asset = nil;
}

- (void)windowDidLoad {
    [super windowDidLoad];
	
	_asset = [[Asset alloc] initWidth:800 height:600];
	
	[_previewArea setWantsLayer:YES];
	_previewArea.layer.backgroundColor = [NSColor blackColor].CGColor;
	
	_timelineView = [[TimelineView alloc] initWithFrame:_timelineArea.bounds];
	_timelineView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[_timelineArea addSubview:_timelineView];

	_timelineArea.wantsLayer = YES;
	_timelineArea.layer.borderWidth = 1;
	
	[self addTrackView];
	[self addTrackView];

	[self addFileClip:@"/Users/ideawu/Downloads/mc-6.png"];
	[self addFileClip:@"/Users/ideawu/Downloads/imgs/1.jpg"];
	[self addFileClip:@"/Users/ideawu/Downloads/imgs/9.jpg"];
	[self addFileClip:@"/Users/ideawu/Downloads/gif/ha.gif"];
	[self addFileClip:@"/Users/ideawu/Downloads/imgs/6.jpg"];
	[self addFileClip:@"/Users/ideawu/Downloads/imgs/2.jpg"];

	[self onAddTransition:nil];
	[self onAddTransition:nil];
	[self onAddTransition:nil];

	_lastRenderTime = -1;
	[self renderAtTime:0];
}

- (void)addTrackView{
	TrackView *tv = [[TrackView alloc] init];
	tv.track = [[Track alloc] init];
	tv.track.layer = (int)_asset.tracks.count;
	[_asset addTrack:tv.track];
	[_timelineView addTrackView:tv];
}

- (IBAction)onAddClip:(id)sender {
	NSMutableArray *fileTypes = [NSMutableArray arrayWithArray:[NSImage imageUnfilteredTypes]];
	[fileTypes removeObject:@"com.adobe.pdf"];
//	[fileTypes addObject:@"svg"];
	
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:YES];
	[panel setCanChooseDirectories:YES];
	[panel setAllowedFileTypes:fileTypes];
	
	NSInteger i = [panel runModal];
	if(i == NSModalResponseOK){
		for(NSURL *url in panel.URLs){
			NSString *file = url.path;
			[self addFileClip:file];
		}
	}
}

- (IBAction)onAddTransition:(id)sender {
	NSUInteger index = NSNotFound;
	for(NSUInteger i=0; i <= _timelineView.currentTrackView.items.count; i++){
		if([_timelineView.currentTrackView canInsertTransitionViewAtIndex:i]){
			index = i;
			break;
		}
	}
	if(index == NSNotFound){
		return;
	}

	Transition *transition = [[Transition alloc] init];
	transition.gapDuration = -0.3;

	TransitionView *tv = [[TransitionView alloc] init];
	tv.transition = transition;
	
	[_timelineView.currentTrackView insertTransitionView:tv atIndex:index];
	
	[_asset debug];
}

- (void)addFileClip:(NSString *)file{
	double duration = 1.2;
	if([file.pathExtension.lowercaseString isEqualToString:@"gif"]){
		a3d::ImageSprite *sprite = a3d::ImageSprite::createFromFile([file cStringUsingEncoding:NSUTF8StringEncoding]);
		if(sprite){
			duration = sprite->duration();
		}
		delete sprite;
	}
	
	NSUInteger index = _timelineView.currentTrackView.items.count;

	Clip *clip = [[Clip alloc] init];
	clip.file = file;
	clip.duration = duration;
	
	ClipView *clipView = [[ClipView alloc] init];
	clipView.title = file.lastPathComponent;
	clipView.clip = clip;

	[_timelineView.currentTrackView insertClipView:clipView atIndex:index];
}

- (void)mouseMoved:(NSEvent *)event{
	NSPoint pos = [_timelineView.currentTrackView convertPoint:event.locationInWindow fromView:nil];
	NSUInteger index = [_timelineView.currentTrackView indexAtPoint:pos];
	ListViewItem *item = [_timelineView.currentTrackView itemAtIndex:index];
	if([item isKindOfClass:[ClipView class]]){
		NSPoint pos = [item convertPoint:event.locationInWindow fromView:nil];
		double ratio = pos.x / item.frame.size.width;
		ClipView *clipView = (ClipView *)item;
		Clip *clip = clipView.clip;
		Transition *pt = [_timelineView.currentTrackView.track transitionBeforeClip:clip];
		Transition *nt = [_timelineView.currentTrackView.track transitionAfterClip:clip];
		double duration = MAX(0, clip.duration - pt.nextAction.duration - nt.prevAction.duration);
		double time = duration * ratio + pt.nextAction.duration;
//		log_debug(@"d: %f, t: %f", duration, time);
		time = ((int)(time * 30.0)) / 30.0;
		if(fabs(time) < 1.0/30){
			time = 0.000;
		}
		if(fabs(time - duration) < 1.0/30){
			time = duration - 0.001;
		}
		time = MAX(0, time);
		
		time += clip.beginTime;
		[self renderAtTime:time];
	}
	if([item isKindOfClass:[TransitionView class]]){
		NSPoint pos = [item convertPoint:event.locationInWindow fromView:nil];
		double ratio = pos.x / item.frame.size.width;
		TransitionView *tranView = (TransitionView *)item;
		Transition *tran = tranView.transition;
//		log_debug(@"%f %f", tran.beginTime, tran.endTime);
		double time = tran.beginTime + tran.duration * ratio;
//		log_debug(@"%f %f", tran.beginTime, tran.duration);
		[self renderAtTime:time];
	}
}

- (void)renderAtTime:(double)time{
	if(time == _lastRenderTime){
		return;
	}
	_lastRenderTime = time;
	
	_timeLabel.stringValue = [NSString stringWithFormat:@"%@/%@", [self formatTime:time], [self formatTime:self.asset.duration]];
	
	[self.asset renderAtTime:time callback:^{
		//		log_debug(@"rendered at time: %.3f", _time);
		CGImageRef image = self.asset.CGImage;
		NSImage *img = [[NSImage alloc] initWithCGImage:image size:NSMakeSize(self.asset.width, self.asset.height)];
		_previewArea.layer.transform = CATransform3DConcat(CATransform3DMakeScale(1, -1, 1), CATransform3DMakeTranslation(0, _previewArea.bounds.size.height, 0));
		_previewArea.layer.contents = img;
		[_previewArea setNeedsDisplay:YES];
	}];
}

- (NSString *)formatTime:(double)time{
	if(fabs(time) < 0.001){
		time = 0;
	}
	int h = ((int)time) / 3600;
	int m = (((int)time) % 3600) / 60;
	int s = (((int)time) % 3600) % 60;
	int ms = round(fabs(time - (int)time) * 10000);
	
	if(h != 0){
		return [NSString stringWithFormat:@"%d:%02d:%02d.%04d", h, m, s, ms];
	}else if(m != 0){
		return [NSString stringWithFormat:@"%d:%02d.%04d", m, s, ms];
	}else{
		return [NSString stringWithFormat:@"%.04fs", time];
	}
}

- (void)keyDown:(NSEvent *)event{
	[self.asset debug];
	unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
	switch(c){
		case NSLeftArrowFunctionKey:{
			break;
		}
		case NSRightArrowFunctionKey:{
			break;
		}
	}
}

@end
