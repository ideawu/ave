//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView.h"

@interface ListView()
@property BOOL allowDragging;
@property BOOL isDragging;
@property ListViewItem *draggingSourceItem;
@property NSUInteger draggingSourceItemIndex;
@property ListViewItem *draggingPlaceHolder;
@end


static NSString *kDraggedType = @"com.ideawu.ave.ListView.Dragging";

@interface ListView (Dragging_private)<NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>

- (void)beginDragging:(NSEvent*)event;

@end
