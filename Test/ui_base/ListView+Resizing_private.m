//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView+Resizing_private.h"

@implementation ListView (Resizing_private)

- (BOOL)isResizeActivatedAtPoint:(NSPoint)pos{
	if(!self.allowResizing){
		return NO;
	}
	BOOL ret = NO;
	ListViewItem *item = [self itemAtPoint:pos];
	if(item){
		if(!item.resizable){
			return NO;
		}
		pos = [item convertPoint:pos fromView:self];
		if(self.isVerticalScroll){
			if(pos.y >= item.frame.size.height - 5){
				ret = YES;
			}
		}else{
			if(pos.x >= item.frame.size.width - 5){
				ret = YES;
			}
		}
	}
	return ret;
}

- (void)beginResizing:(NSEvent *)event{
	NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
	ListViewItem *item = [self itemAtPoint:pos];
	if(!item){
		return;
	}
	
	self.isResizing = YES;
	self.resizeStartPoint = pos;
	self.resizeItemOriginSize = item.frame.size;
	self.resizeItem = item;
	
	NSCursor *cursor = self.isVerticalScroll? [NSCursor resizeUpDownCursor] : [NSCursor resizeLeftRightCursor];
	[cursor set];
	[[self window] disableCursorRects];
}

- (void)resizingUpdated:(NSEvent *)event{
	NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
	NSSize size = self.resizeItemOriginSize;
	if(self.isVerticalScroll){
		size.height += pos.y - self.resizeStartPoint.y;
		size.height = MAX(size.height, 0);
	}else{
		size.width += pos.x - self.resizeStartPoint.x;
		size.width = MAX(size.width, 0);
	}
	[self resizeItemToSize:size];
}

- (void)didEndResizing{
	[self endResizeItem];
}

- (void)cancelResizing{
	[self resizeItemToSize:self.resizeItemOriginSize];
	[self endResizeItem];
}

- (void)resizeItemToSize:(NSSize)size{
	if([self.resizingDelegate respondsToSelector:@selector(listView:canResizeItem:toSize:)]){
		BOOL ret = [self.resizingDelegate listView:self canResizeItem:self.resizeItem toSize:size];
		if(!ret){
			return;
		}
	}
	
	[self.resizeItem setFrameSize:size];
	[self setNeedsLayout:YES];
	
	if([self.resizingDelegate respondsToSelector:@selector(listView:updatedResizeItem:)]){
		[self.resizingDelegate listView:self updatedResizeItem:self.resizeItem];
	}
}

- (void)endResizeItem{
	self.isResizing = NO;
	[[NSCursor arrowCursor] set];
	[[self window] enableCursorRects];
	[[self window] resetCursorRects];
	
	if([self.resizingDelegate respondsToSelector:@selector(listView:didEndResizeItem:)]){
		[self.resizingDelegate listView:self didEndResizeItem:self.resizeItem];
	}
}

@end
