//  Created by ideawu on 2019/2/28.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView.h"
#import "ListView+Items_private.h"
#import "ListView+Resizing_private.h"
#import "ListView+Dragging_private.h"
#import "ListViewScrollView.h"
#import "FlippedView.h"

@interface ListView(){
	BOOL _isVerticalScroll;
	id eventMonitor;
}
@property ListViewScrollView *scrollView;
//@property FlipView *contentView;
@property NSTrackingArea *trackingArea;
@property BOOL mouseDraggingWillBegin;
@end


@implementation ListView

- (void)setup{
	[super setup];
	_items = [[NSMutableArray alloc] init];
	
	_documentView = [[FlippedView alloc] init];
	
	_scrollView = [[ListViewScrollView alloc] init];
	_scrollView.listView = self;
	_scrollView.drawsBackground = NO;
	_scrollView.documentView = _documentView;
	[self addSubview:_scrollView];

	[self setIsVerticalScroll:YES];
	[self allowResizing:NO];
	[self allowDragging:NO];
	[self layout];
	
	// monitor ESC key
	__weak typeof(self) me = self;
	NSEvent* (^handler)(NSEvent*) = ^(NSEvent *event) {
		if (event.window != me.window) {
			return event;
		}
		if (event.keyCode == 53) {
			[me keyDown:event];
			return (NSEvent *)nil;
		}
		return event;
	};
	eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:handler];
}

- (void)dealloc{
	log_debug(@"%s %@", __func__, self);
	if(eventMonitor){
		[NSEvent removeMonitor:eventMonitor];
		eventMonitor = nil;
	}
}

- (BOOL)isVerticalScroll{
	return _isVerticalScroll;
}

- (void)setIsVerticalScroll:(BOOL)isVertical{
	_isVerticalScroll = isVertical;
	if(_isVerticalScroll){
		_scrollView.hasVerticalScroller = YES;
		_scrollView.hasHorizontalScroller = NO;
		_scrollView.verticalScrollElasticity = NSScrollElasticityAllowed;
		_scrollView.horizontalScrollElasticity = NSScrollElasticityNone;
	}else{
		_scrollView.hasVerticalScroller = NO;
		_scrollView.hasHorizontalScroller = YES;
		_scrollView.verticalScrollElasticity = NSScrollElasticityNone;
		_scrollView.horizontalScrollElasticity = NSScrollElasticityAllowed;
	}
}

- (void)setFrameSize:(NSSize)newSize{
	[super setFrameSize:newSize];
	[self layout];
}

- (void)layout{
	[super layout];
	NSEdgeInsets borderEdge = self.style.borderEdge;
	NSRect frame = self.style.bounds;
	frame.origin.x -= borderEdge.left;
	frame.origin.y -= borderEdge.top;
	frame.size.width += borderEdge.left + borderEdge.right;
	frame.size.height += borderEdge.top + borderEdge.bottom;
	[_scrollView setFrame:frame];
	[self layoutItems];
}

- (NSPoint)contentOffset{
	return _scrollView.contentView.bounds.origin;
}

- (void)setContentOffset:(NSPoint)contentOffset{
	[_scrollView.contentView scrollToPoint:contentOffset];
	[_scrollView reflectScrolledClipView:_scrollView.contentView];
}

- (NSSize)viewportSize{
	return _scrollView.contentView.bounds.size;
}


#pragma mark - List Item operation

- (void)beginAnimationGrouping{
	_isAnimationGrouping = YES;
	[NSAnimationContext beginGrouping];
	NSAnimationContext.currentContext.duration = 1;
}

- (void)endAnimationGrouping{
	_isAnimationGrouping = NO;
	[NSAnimationContext endGrouping];
}

#pragma mark - Mouse

- (void)mouseMoved:(NSEvent *)event{
	[super mouseMoved:event];
	if(self.allowResizing){
		NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
		if([self isResizeActivatedAtPoint:pos]){
			NSCursor *cursor = self.isVerticalScroll? [NSCursor resizeUpDownCursor] : [NSCursor resizeLeftRightCursor];
			[cursor set];
			[[self window] disableCursorRects];
		}else{
			[[NSCursor arrowCursor] set];
			[[self window] enableCursorRects];
			[[self window] resetCursorRects];
		}
	}
}

- (void)mouseExited:(NSEvent *)event{
	[super mouseExited:event];
	if(self.allowResizing){
		[[NSCursor arrowCursor] set];
	}
}

- (void)mouseDown:(NSEvent*)event{
	[super mouseDown:event];
	_mouseDraggingWillBegin = YES;

	NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
	ListViewItem *item = [self itemAtPoint:pos];
	ListViewItem *prev = _selectedItem;
	_selectedItem = item;
	
	if(item != prev){
		if(self.delegate){
			if(prev){
				[self.delegate listView:self unselectedItem:prev];
			}
			if(item){
				[self.delegate listView:self selectedItem:item];
			}
		}
	}
	
	for(ListViewItem *i in self.items){
		i.selected = (i == _selectedItem);
	}
}

- (void)mouseUp:(NSEvent *)event{
	[super mouseUp:event];
	if(self.isResizing){
		[self didEndResizing];
	}
}

- (void)mouseDragged:(NSEvent *)event{
	[super mouseDragged:event];
	if(_mouseDraggingWillBegin){
		_mouseDraggingWillBegin = NO;
		
		NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
		if([self isResizeActivatedAtPoint:pos]){
			[self beginResizing:event];
		}else{
			[self beginDragging:event];
		}
	}
	
	if(self.isResizing){
		[self resizingUpdated:event];
	}
}

#pragma mark - Keyboard and Mouse event handle

//- (BOOL)acceptsFirstResponder{
//	return YES;
//}

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

- (void)keyDown:(NSEvent *)event{
	unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
	switch(c){
		case 27:{
			if(self.isResizing){
				[self cancelResizing];
			}
			break;
		}
	}
}

@end
