//  Created by ideawu on 2019/2/28.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ListViewItem.h"
#import "IView.h"

@class ListView;
@protocol ListViewDelegate;
@protocol ListViewResizingDelegate;
@protocol ListViewDraggingDelegate;


@interface ListView : IView{
	NSSize _contentSize;
	NSView *_documentView;
	NSMutableArray<ListViewItem *> *_items;
}
// TODO: headerView footerView, headerBar, footerBar

@property (readonly) NSScrollView *scrollView;

@property NSPoint contentOffset;

@property (readonly) NSSize contentSize;
/** 不包括滚动条 */
@property (readonly) NSSize viewportSize;

@property (readonly) ListViewItem *selectedItem;

@property BOOL isVerticalScroll;

@property (readonly) BOOL isAnimationGrouping;

- (void)beginAnimationGrouping;
- (void)endAnimationGrouping;

@property (nonatomic, weak) id<ListViewDelegate> delegate;
@property (nonatomic, weak) id<ListViewDraggingDelegate> draggingDelegate;
@property (nonatomic, weak) id<ListViewResizingDelegate> resizingDelegate;

@end


@protocol ListViewDelegate<NSObject>
@required
- (void)listView:(ListView *)listView selectedItem:(ListViewItem *)item;
- (void)listView:(ListView *)listView unselectedItem:(ListViewItem *)item;
@end

#import "ListView+Items.h"
#import "ListView+Resizing.h"
#import "ListView+Dragging.h"
