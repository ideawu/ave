//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView+Dragging_private.h"
#import "ListView+Items_private.h"

@implementation ListView (Dragging_private)

- (void)beginDragging:(NSEvent*)event{
	if(!self.allowDragging){
		return;
	}
	
	NSPoint pos = [self convertPoint:event.locationInWindow fromView:nil];
	ListViewItem *item = [self itemAtPoint:pos];
	if(!item){
		return;
	}
	NSUInteger index = [self indexOfItem:item];
	if([self.draggingDelegate respondsToSelector:@selector(listView:canDragItem:fromIndex:)]){
		if(![self.draggingDelegate listView:self canDragItem:item fromIndex:index]){
			return;
		}
	}

	self.isDragging = YES;
	self.draggingSourceItem = item;
	self.draggingSourceItemIndex = index;
	log_debug(@"begin drag at: %d", self.draggingSourceItemIndex);

	// NSPasteboardItem 用于在 drag-n-drap 的双方之间进行通信
	NSPasteboardItem *pbItem = [NSPasteboardItem new];
	// 指定要传输的数据类型，最后要传输的数据由 NSPasteboardItemDataProvider 提供。
	// 你可以自定义一个类型，是一个字符串。
	[pbItem setDataProvider:self forTypes:@[kDraggedType]];
	// NSDraggingItem 用于显示 drag-n-drop 过程的示意图
	NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:pbItem];
//	NSImage *img = [NSImage imageNamed:NSImageNameHomeTemplate];
	NSImage *img = [item snapshot];
	{
		[img lockFocus];
		[@"Test" drawAtPoint:NSZeroPoint withAttributes:nil];
		[img unlockFocus];
	}
	NSRect frame = NSMakeRect(pos.x - img.size.width/2, pos.y - img.size.height/2, img.size.width, img.size.height);
	// draggingFrame 用于指定示意图的初始位置（在当前 NSView 中），contents 是示意图（NSImage）
	[dragItem setDraggingFrame:frame contents:img];
	
	// 当你决定 drag-n-drop 可以开始的时候，调用此方法
	[self beginDraggingSessionWithItems:@[dragItem] event:event source:self];

	[self setupPlaceholder];
	[self removeItem:self.draggingSourceItem];
	[self insertItem:self.draggingPlaceHolder atIndex:self.draggingSourceItemIndex];
	
	if([self.draggingDelegate respondsToSelector:@selector(listView:beganDragItem:fromIndex:)]){
		[self.draggingDelegate listView:self
						  beganDragItem:self.draggingSourceItem
							  fromIndex:self.draggingSourceItemIndex];
	}
}

- (NSUInteger)indexOfDroppingPoint:(NSPoint)pos{
	if(self.items.count == 0){
		return 0;
	}
	if(self.items.count == 1 && self.draggingPlaceHolder.superview){
		return 0;
	}
	
	NSUInteger index = [self indexAtPoint:pos]; // 不做 hitTest
	ListViewItem *item = [self itemAtIndex:index];
	if(item){
		if(item == self.draggingPlaceHolder){
			return index;
		}
		
		NSPoint p = [item convertPoint:pos fromView:self];
		if(self.isVerticalScroll){
			if(p.y > item.frame.size.height/2){
				index += 1;
			}
		}else{
			if(p.x > item.frame.size.width/2){
				index += 1;
			}
		}
	}
	return index;
}

- (void)setupPlaceholder{
	//	log_debug(@"create");
	self.draggingPlaceHolder = [[ListViewItem alloc] init];
	[self.draggingPlaceHolder.style set:@"border-radius: 5"];
//	self.draggingPlaceHolder.wantsLayer = YES;
//	self.draggingPlaceHolder.layer.borderWidth = 1;
	
	NSSize size = self.viewportSize;
	if(self.draggingSourceItem){ // dragging source
//		self.draggingPlaceHolder.layer.borderColor = [NSColor redColor].CGColor;
		[self.draggingPlaceHolder.style set:@"border: 1 dashed #f00"];
		size = self.draggingSourceItem.frame.size;
	}else{
//		self.draggingPlaceHolder.layer.borderColor = [NSColor blueColor].CGColor;
		[self.draggingPlaceHolder.style set:@"border: 1 dashed #00f"];
		if(self.isVerticalScroll){
			size.height = 10;
		}else{
			size.width = 10;
		}
	}
	[self.draggingPlaceHolder setFrameSize:size];
}

- (void)releasePlaceHolder{
	//	log_debug(@"release");
	if(self.draggingPlaceHolder){
		[self beginAnimationGrouping];
		[self removeItem:self.draggingPlaceHolder];
		[self endAnimationGrouping];
		self.draggingPlaceHolder = nil;
	}
}


#pragma mark - NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context{
	//	log_debug(@"%s", __func__);
	return NSDragOperationMove;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation{
	//	log_debug(@"%s", __func__);

	[self releasePlaceHolder];

	if(operation == NSDragOperationNone){
		log_debug(@"cancel drag at: %d", self.draggingSourceItemIndex);
		[self beginAnimationGrouping];
		[self insertItem:self.draggingSourceItem atIndex:self.draggingSourceItemIndex];
		[self endAnimationGrouping];
		if([self.draggingDelegate respondsToSelector:@selector(listView:cancelDragItem:fromIndex:)]){
			[self.draggingDelegate listView:self
							 cancelDragItem:self.draggingSourceItem
								  fromIndex:self.draggingSourceItemIndex];
		}
	}else if(operation == NSDragOperationMove){
		if(self.draggingDelegate){
			[self.draggingDelegate listView:self
							  endedDragItem:self.draggingSourceItem
								  fromIndex:self.draggingSourceItemIndex];
		}
	}

	self.draggingSourceItem = nil;
	self.draggingSourceItemIndex = NSNotFound;
	self.isDragging = NO;
}


#pragma mark - NSDraggingDestination

- (BOOL)wantsPeriodicDraggingUpdates{
	return NO;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender{
//		log_debug(@"%s", __func__);
	if(sender.draggingSource == self){
		// 在删除前，仍然在原位显示 placeholder
		[self beginAnimationGrouping];
		[self removeItem:self.draggingPlaceHolder];
		[self insertItem:self.draggingPlaceHolder atIndex:self.draggingSourceItemIndex];
		[self endAnimationGrouping];
	}else{
		[self releasePlaceHolder];
	}
}

- (id)readDraggingObject:(NSPasteboard *)pb{
	NSData *data = [pb dataForType:kDraggedType];
	if(!data){
		return nil;
	}
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	id obj = [self.draggingDelegate listView:self decodeData:[array objectAtIndex:1]];
	return obj;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender{
//		log_debug(@"%s", __func__);
	NSPoint pos = [self convertPoint:sender.draggingLocation fromView:nil];
	NSUInteger index = [self indexOfDroppingPoint:pos];
	NSUInteger pindex = [self indexOfItem:self.draggingPlaceHolder];

	if(index == pindex || index == pindex + 1){
		return NSDragOperationMove;
	}
//	log_debug(@"may drop at: %d", index);
	
	if([self.draggingDelegate respondsToSelector:@selector(listView:canDropObject:toIndex:)]){
		id obj = [self readDraggingObject:[sender draggingPasteboard]];
		if(!obj){
			return NSDragOperationNone;
		}
		if(![self.draggingDelegate listView:self canDropObject:obj toIndex:index]){
			return NSDragOperationNone;
		}
	}

	// 设置 placeholder 的初始位置
	if(!self.draggingPlaceHolder){
		[self setupPlaceholder];
		[self insertItem:self.draggingPlaceHolder atIndex:index];
		[self removeItem:self.draggingPlaceHolder];
	}
	
	NSUInteger pi = [self indexOfItem:self.draggingPlaceHolder];
	if(pi < index){
		// placeholder remove 后，目标 index 应该前移一位
		index -= 1;
	}
	[self beginAnimationGrouping];
	[self removeItem:self.draggingPlaceHolder];
	[self insertItem:self.draggingPlaceHolder atIndex:index];
	[self endAnimationGrouping];
	
	return NSDragOperationMove;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
	if(sender.draggingSource == self){
		NSUInteger index = [self indexOfItem:self.draggingPlaceHolder];
		if(index == self.draggingSourceItemIndex){
			return NO;
		}
	}
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
	NSUInteger index = [self indexOfItem:self.draggingPlaceHolder];

	if(sender.draggingSource == self){
		log_debug(@"should move drag item: %lu => %lu", self.draggingSourceItemIndex, index);
		[self removeItem:self.draggingPlaceHolder];
	}else{
		log_debug(@"should drop at: %d", index);
		[self releasePlaceHolder];
	}

	BOOL ret = NO;
	if(self.draggingDelegate){
		id obj;
		if(sender.draggingSource == self){
			obj = self.draggingSourceItem;
		}else{
			obj = [self readDraggingObject:[sender draggingPasteboard]];
		}
		if(obj){
			ret = [self.draggingDelegate listView:self performDropObject:obj toIndex:index];
		}
	}else{
		// auto re-order item
		id obj = self.draggingSourceItem;
		[self insertItem:obj atIndex:index];
		ret = YES;
	}
	
	if(sender.draggingSource == self){
		// 因为源收到结束消息是异步有延时的，所以这里把占位符放回去
		if(!ret){
			[self insertItem:self.draggingPlaceHolder atIndex:index];
		}
	}
	
	return ret;
}


#pragma mark - NSPasteboardItemDataProvider

- (void)pasteboard:(NSPasteboard *)pasteboard item:(NSPasteboardItem *)item provideDataForType:(NSPasteboardType)type{
	//	log_debug(@"%s", __func__);
	if([type isEqualToString:kDraggedType]){
		NSData *itemData = nil;
		if(self.draggingDelegate){
			itemData = [self.draggingDelegate listView:self encodeItem:self.draggingSourceItem];
		}
		if(itemData){
			NSArray *array = @[@(self.draggingSourceItemIndex), itemData];
			NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
			[pasteboard setData:data forType:kDraggedType];
		}else{
			// 不能设置 nil，会导致 [pb dataForType:kDraggedType]; 返回的不是 nil
			// [pasteboard setData:nil forType:kDraggedType];
		}
	}
}

@end
