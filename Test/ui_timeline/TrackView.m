//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "TrackView.h"

@interface TrackView()<ListViewDraggingDelegate, ListViewResizingDelegate>
@end


@implementation TrackView

- (void)setup{
	[super setup];
	
	[self setFrameSize:NSMakeSize(0, 80)];
	[self.style set:@"border-bottom: 1 solid #000; padding: 2;"];

	self.isVerticalScroll = NO;
	self.resizingDelegate = self;
	self.draggingDelegate = self;
	[self allowDragging:YES];
	[self allowResizing:YES];
}

- (void)dealloc{
	log_debug(@"%s %@", __func__, self);
}

- (CGFloat)durationToWidth:(double)duration{
	return duration * 100.0;
}

- (double)widthToDuration:(CGFloat)width{
	return width/100.0;
}

- (void)insertClipView:(ClipView *)cv atIndex:(NSUInteger)index{
	ListViewItem *prev = (ListViewItem *)[self itemAtIndex:index-1];
	ListViewItem *next = (ListViewItem *)[self itemAtIndex:index];
	
	// 获取 beginTime
	double beginTime = 0;
	if([prev isKindOfClass:[ClipView class]]){
		beginTime = [(ClipView *)prev clip].endTime;
	}else if([prev isKindOfClass:[TransitionView class]]){
		beginTime = [(TransitionView *)prev transition].prevAction.endTime;
	}
	
	// 移除 transition
	if([prev isKindOfClass:[TransitionView class]]){
		[self.track removeTransition:[(TransitionView *)prev transition]];
	}
	if([next isKindOfClass:[TransitionView class]]){
		[self.track removeTransition:[(TransitionView *)next transition]];
	}
	
	cv.duration = cv.clip.duration;
	cv.clip.beginTime = beginTime;
	if(![self.track canInsertClipAtTime:cv.clip.beginTime]){
		log_error(@"#########################################################");
		log_debug(@"%f", cv.clip.beginTime);
		[self.track debug];
		exit(0);
	}
	[self.track insertClip:cv.clip];
	
	// 重新绑定 transition
	if([prev isKindOfClass:[TransitionView class]]){
		[[(TransitionView *)prev transition] setNextClip:cv.clip];
		[self.track addTransition:[(TransitionView *)prev transition]];
	}
	if([next isKindOfClass:[TransitionView class]]){
		[[(TransitionView *)next transition] setPrevClip:cv.clip];
		[self.track addTransition:[(TransitionView *)next transition]];
	}
	
	[cv setFrameSize:NSMakeSize([self durationToWidth:cv.clip.duration], self.viewportSize.height)];
	[self insertItem:cv atIndex:index];
}

- (BOOL)canInsertTransitionViewAtIndex:(NSUInteger)index{
	ListViewItem *old;
	old = [self itemAtIndex:index];
	if(old && [old isKindOfClass:[TransitionView class]]){
		return NO;
	}
	old = [self itemAtIndex:index-1];
	if(old && [old isKindOfClass:[TransitionView class]]){
		return NO;
	}
	return YES;
}

- (void)insertTransitionView:(TransitionView *)tv atIndex:(NSUInteger)index{
	ListViewItem *prev = (ListViewItem *)[self itemAtIndex:index-1];
	ListViewItem *next = (ListViewItem *)[self itemAtIndex:index];
	
	// 绑定 transition
	if([prev isKindOfClass:[ClipView class]]){
		[tv.transition setPrevClip:[(ClipView *)prev clip]];
	}
	if([next isKindOfClass:[ClipView class]]){
		[tv.transition setNextClip:[(ClipView *)next clip]];
	}
	[self.track addTransition:tv.transition];
	
	[self insertItem:tv atIndex:index];
}

#pragma mark - ListView resize

- (BOOL)listView:(ListView *)listView canResizeItem:(ListViewItem *)item toSize:(NSSize)size{
	if([item isKindOfClass:[TransitionView class]]){
		return NO;
	}
	return size.width >= [self durationToWidth:0.1];
}

- (void)listView:(ListView *)listView updatedResizeItem:(ListViewItem *)item{
	[(ClipView *)item setDuration:[self widthToDuration:item.frame.size.width]];
}

- (void)listView:(ListView *)listView didEndResizeItem:(ListViewItem *)item{
	NSUInteger index = [self indexOfItem:item];
	ClipView *cv = (ClipView *)item;

	[self removeItem:cv];
	[self.track removeClip:cv.clip];
	
	cv.clip.duration = cv.duration;
	[self insertClipView:cv atIndex:index];
}


#pragma mark - ListView drag and drop

- (NSData *)listView:(ListView *)listView encodeItem:(ListViewItem *)item {
	if([item isKindOfClass:[ClipView class]]){
		return [NSKeyedArchiver archivedDataWithRootObject:item];
	}
	if([item isKindOfClass:[TransitionView class]]){
		return [NSKeyedArchiver archivedDataWithRootObject:item];
	}
	return nil;
}

- (id)listView:(ListView *)listView decodeData:(NSData *)data{
	return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)listView:(ListView *)listView endedDragItem:(ListViewItem *)item fromIndex:(NSUInteger)fromIndex{
	if([item isKindOfClass:[ClipView class]]){
		ListViewItem *prev = [listView itemAtIndex:fromIndex-1];
		ListViewItem *next = [listView itemAtIndex:fromIndex];
		if([prev isKindOfClass:[TransitionView class]]){
			[listView removeItem:prev];
		}
		if([next isKindOfClass:[TransitionView class]]){
			[listView removeItem:next];
		}
		
		ClipView *cv = (ClipView *)item;
		[self.track removeClip:cv.clip];
	}

	if([item isKindOfClass:[TransitionView class]]){
		TransitionView *tv = (TransitionView *)item;
		[self.track removeTransition:tv.transition];
	}
}

- (BOOL)listView:(ListView *)listView canDropObject:(id)obj toIndex:(NSUInteger)toIndex{
	if([obj isKindOfClass:[TransitionView class]]){
		if(![self canInsertTransitionViewAtIndex:toIndex]){
			return NO;
		}
	}
	return YES;
}

- (BOOL)listView:(ListView *)listView performDropObject:(id)obj toIndex:(NSUInteger)toIndex {
	if([obj isKindOfClass:[TransitionView class]]){
		[self insertTransitionView:(TransitionView *)obj atIndex:toIndex];
	}
	if([obj isKindOfClass:[ClipView class]]){
		[self insertClipView:(ClipView *)obj atIndex:toIndex];
	}

	return YES;
}

@end
