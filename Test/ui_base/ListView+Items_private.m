//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView+Items_private.h"

@implementation ListView (Items_private)

- (void)layoutItems{
//		log_debug("%s %d %@", __func__, _items.count, self);
	NSEdgeInsets edge = self.style.padding;
	CGFloat w = self.viewportSize.width;
	CGFloat h = self.viewportSize.height;
	CGFloat x = 0;
	CGFloat y = 0;
	w -= edge.left + edge.right;
	h -= edge.top + edge.bottom;
	x += edge.left;
	y += edge.top;
	for(ListViewItem *item in self.items){
		if(self.isAnimationGrouping){
			[item.animator setFrameOrigin:NSMakePoint(x, y)];
		}else{
			[item setFrameOrigin:NSMakePoint(x, y)];
		}
		if(self.isVerticalScroll){
			y = item.frame.origin.y + item.frame.size.height;
			[item setFrameSize:NSMakeSize(w, item.frame.size.height)];
//			log_debug(@"item: %.1f %.1f", item.frame.size.width, item.frame.size.height);
		}else{
			x = item.frame.origin.x + item.frame.size.width;
			[item setFrameSize:NSMakeSize(item.frame.size.width, h)];
//			log_debug(@"item: %.1f %.1f", item.frame.size.width, item.frame.size.height);
		}
//		log_debug(@"%.1f", item.layer.bounds.size.height);
	}
	if(self.isVerticalScroll){
		_contentSize = NSMakeSize(w, y - edge.top);
	}else{
		_contentSize = NSMakeSize(x - edge.left, h);
	}
	NSSize size = _contentSize;
	size.width += edge.left + edge.right;
	size.height += edge.top + edge.bottom;
	size.width = MAX(size.width, self.viewportSize.width);
	size.height = MAX(size.height, self.viewportSize.height);
	[_documentView setFrameSize:size];
}

@end
