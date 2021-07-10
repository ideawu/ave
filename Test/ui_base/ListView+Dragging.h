//  Created by ideawu on 3/1/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView.h"

@protocol ListViewDraggingDelegate <NSObject>
@required

- (NSData *)listView:(ListView *)listView encodeItem:(ListViewItem *)item;
- (id)listView:(ListView *)listView decodeData:(NSData *)data;

- (void)listView:(ListView *)listView endedDragItem:(ListViewItem *)item fromIndex:(NSUInteger)fromIndex;
- (BOOL)listView:(ListView *)listView performDropObject:(id)obj toIndex:(NSUInteger)toIndex;

@optional
- (BOOL)listView:(ListView *)listView canDragItem:(ListViewItem *)item fromIndex:(NSUInteger)fromIndex;
- (void)listView:(ListView *)listView beganDragItem:(ListViewItem *)item fromIndex:(NSUInteger)fromIndex;
- (void)listView:(ListView *)listView cancelDragItem:(ListViewItem *)item fromIndex:(NSUInteger)fromIndex;
- (BOOL)listView:(ListView *)listView canDropObject:(id)obj toIndex:(NSUInteger)toIndex;
@end


@interface ListView (Dragging)

- (void)allowDragging:(BOOL)allow;

@end
