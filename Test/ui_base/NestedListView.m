//  Created by ideawu on 3/12/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "NestedListView.h"

@interface NestedListView()
@end

@implementation NestedListView

- (void)setup{
	[super setup];
	
	_scrollView = [[NSScrollView alloc] init];
	_scrollView.drawsBackground = NO;
	_scrollView.hasVerticalScroller = YES;
	_scrollView.hasHorizontalScroller = YES;
	_scrollView.verticalScrollElasticity = NSScrollElasticityAllowed;
	_scrollView.horizontalScrollElasticity = NSScrollElasticityAllowed;
	_scrollView.documentView = [[IView alloc] init];
	_scrollView.postsBoundsChangedNotifications = YES;
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(scrollViewDidScroll:)
											   name:NSViewBoundsDidChangeNotification
											 object:_scrollView.contentView];
	[self addSubview:_scrollView];

	_mainListView = [[ListView alloc] init];
	[_mainListView allowDragging:NO];
	[_mainListView allowResizing:NO];
	_mainListView.isVerticalScroll = YES;
	_mainListView.scrollView.hasVerticalScroller = NO;
	_mainListView.scrollView.hasHorizontalScroller = NO;
	
//	[_scrollView.documentView addSubview:_mainListView];
	[self addSubview:_mainListView]; // 覆盖在 scrollview 之上
}
- (NSSize)viewportSize{
	return _scrollView.contentView.bounds.size;
}

- (void)setFrameSize:(NSSize)newSize{
	[super setFrameSize:newSize];
	[self layout];
}

- (void)layout{
	[super layout];
	
	_scrollView.frame = self.style.bounds;
	[_mainListView setFrameSize:_scrollView.contentView.bounds.size];

	for(ListViewItem *item in _mainListView.items){
		[item setFrameSize:NSMakeSize(_mainListView.viewportSize.width, item.frame.size.height)];
	}
}

- (void)scrollViewDidScroll:(NSNotification *)notification{
	NSPoint offset = [(NSClipView *)notification.object bounds].origin;
	NSPoint subOffset = NSMakePoint(offset.x, 0);
	NSPoint mainOffset = NSMakePoint(0, offset.y);
//	[_mainListView setFrameOrigin:offset];

	for(ListViewItem *item in _mainListView.items){
		ListView *sub = (ListView *)item.contentView;
		sub.contentOffset = subOffset;
	}
	
	_mainListView.contentOffset = mainOffset;
}

- (void)subListViewDidResize:(NSNotification *)notification{
	CGFloat width = 0;
	for(ListViewItem *item in _mainListView.items){
		ListView *sub = (ListView *)item.contentView;
		width = MAX(width, sub.contentSize.width);
	}
	CGFloat height = _mainListView.contentSize.height;
	[_scrollView.documentView setFrameSize:NSMakeSize(width, height)];
}

- (void)addSubListView:(ListView *)subListView{
	[self insertSubListView:subListView atIndex:_mainListView.items.count];
}

- (void)insertSubListView:(ListView *)subListView atIndex:(NSUInteger)index{
	subListView.scrollView.hasVerticalScroller = NO;
	subListView.scrollView.hasHorizontalScroller = NO;
	subListView.scrollView.verticalScrollElasticity = NSScrollElasticityNone;
	subListView.scrollView.horizontalScrollElasticity = NSScrollElasticityNone;
	
	ListViewItem *item = [[ListViewItem alloc] init];
	[item setContentView:subListView];
	[_mainListView insertItem:item atIndex:index];
	
	[subListView.scrollView.documentView setPostsFrameChangedNotifications:YES];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(subListViewDidResize:)
											   name:NSViewFrameDidChangeNotification
											 object:subListView.scrollView.documentView];
}

@end
