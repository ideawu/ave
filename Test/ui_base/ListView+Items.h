//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView.h"

@interface ListView (Items)

- (NSArray<ListViewItem *> *)items;

- (ListViewItem *)itemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfItem:(ListViewItem *)item;

/** local point, 需要做 hitTest */
- (ListViewItem *)itemAtPoint:(NSPoint)pos;
/** local point, 不需要做 hitTest */
- (NSUInteger)indexAtPoint:(NSPoint)pos;

- (void)addItem:(ListViewItem *)item;
- (void)insertItem:(ListViewItem *)item atIndex:(NSUInteger)index;
- (void)removeItem:(ListViewItem *)item;

@end
