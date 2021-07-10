//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "TimelineView.h"
#import "TrackView.h"
#import "NestedListView.h"

@interface TimelineView()<ListViewDelegate>
@property NSTrackingArea *trackingArea;
@property NSMutableArray<TrackView*> *trackViews;
@property NestedListView *mainView;
@end

@implementation TimelineView

- (void)setup{
	[super setup];
	_trackViews = [[NSMutableArray alloc] init];
	
	_mainView = [[NestedListView alloc] init];
	_mainView.mainListView.delegate = self;
	[self addSubview:_mainView];
	
	_previewMarker = [[IView alloc] init];
	_previewMarker.userInteractionEnabled = NO;
	[_previewMarker.style set:@"border: 1 solid #666"];
	[self addSubview:_previewMarker];
}

- (void)dealloc{
	log_debug(@"%s", __func__);
}

- (void)setFrameSize:(NSSize)newSize{
	[super setFrameSize:newSize];
	[self layout];
}

- (void)layout{
	[super layout];

	[_mainView setFrameSize:self.frame.size];
	[_previewMarker setFrameSize:NSMakeSize(1, _mainView.viewportSize.height)];
}

- (TrackView *)currentTrackView{
	if(_mainView.mainListView.selectedItem){
		return (TrackView *)_mainView.mainListView.selectedItem.contentView;
	}
	return _trackViews.firstObject;
}

- (void)addTrackView:(TrackView *)tv{
	// 在上的TrackView的layer大
	[_mainView insertSubListView:tv atIndex:0];
	[_trackViews addObject:tv];
}

- (void)listView:(ListView *)listView selectedItem:(ListViewItem *)item {
	[item.contentView.style set:@"border-bottom: 1 solid #990"];
}

- (void)listView:(ListView *)listView unselectedItem:(ListViewItem *)item {
	[item.contentView.style set:@"border-bottom: 1 solid #333"];
}

#pragma mark - Mouse and Keyboard

- (void)updateTrackingAreas{
	if(_trackingArea){
		[self removeTrackingArea:_trackingArea];
	}
	NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
									 NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
	_trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
												 options:options
												   owner:self
												userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

- (void)mouseMoved:(NSEvent *)event{
	[super mouseMoved:event];
	NSPoint pos = [_mainView convertPoint:event.locationInWindow fromView:nil];
	if(pos.x > _mainView.viewportSize.width){
		pos.x = -1;
	}
	if(pos.y > _mainView.viewportSize.height){
		return;
	}
	[_previewMarker setFrameOrigin:NSMakePoint(pos.x, 0)];
}

- (void)mouseDown:(NSEvent *)event{
	[super mouseDown:event];
//	NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
}

@end
