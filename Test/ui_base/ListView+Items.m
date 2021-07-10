//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView+Items.h"
#import "ListView+Items_private.h"

@implementation ListView (Items)

- (NSArray<ListViewItem *> *)items{
	return _items;
}

- (void)addItem:(ListViewItem *)item{
	[self insertItem:item atIndex:self.items.count];
}

- (void)insertItem:(ListViewItem *)item atIndex:(NSUInteger)index{
	if(index > self.items.count){
		index = self.items.count;
	}
	
	if(self.isAnimationGrouping){
		// 在动画前，先初始化要插入的节点的位置
		NSPoint pos = NSZeroPoint;
		if(index < self.items.count){
			ListViewItem *old = [self.items objectAtIndex:index];
			pos = old.frame.origin;
		}else{
			if(self.isVerticalScroll){
				pos.y = self.contentSize.height;
			}else{
				pos.x = self.contentSize.width;
			}
		}
		[item setFrameOrigin:pos];
	}
	
	item.listView = self;
	[_items insertObject:item atIndex:index];
	[_documentView addSubview:item];
	[self layout];
}

- (void)removeItem:(ListViewItem *)item{
	NSUInteger index = [self.items indexOfObject:item];
	if(index != NSNotFound){
		[self removeItemAtIndex:index];
	}
}

- (void)removeItemAtIndex:(NSUInteger)index{
	if(index >= self.items.count){
		return;
	}
	ListViewItem *item = [self.items objectAtIndex:index];
	[item removeFromSuperview];
	[_items removeObjectAtIndex:index];
	[self layout];
}

- (ListViewItem *)itemAtIndex:(NSUInteger)index{
	if(index >= self.items.count){
		return nil;
	}
	return [self.items objectAtIndex:index];
}

- (NSUInteger)indexOfItem:(ListViewItem *)item{
	return [self.items indexOfObject:item];
}

- (ListViewItem *)itemAtPoint:(NSPoint)pos{
	pos = [_documentView convertPoint:pos fromView:self];
	for(NSUInteger i=0; i<self.items.count; i++){
		ListViewItem *item = [self.items objectAtIndex:i];
		if([item hitTest:pos]){
			return item;
		}
	}
	return nil;
}

- (NSUInteger)indexAtPoint:(NSPoint)pos{
	pos = [_documentView convertPoint:pos fromView:self];
	for(NSUInteger i=0; i<self.items.count; i++){
		ListViewItem *item = [self.items objectAtIndex:i];
		NSRect frame = item.frame;
		if(self.isVerticalScroll){
			if(pos.y <= frame.origin.y + frame.size.height){
				return i;
			}
		}else{
			if(pos.x <= frame.origin.x + frame.size.width){
				return i;
			}
		}
	}
	return self.items.count;
}


@end
