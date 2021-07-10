//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView.h"

@interface ListView()
@property BOOL allowResizing;
@property BOOL isResizing;
@property NSPoint resizeStartPoint;
@property NSSize resizeItemOriginSize;
@property (weak) ListViewItem *resizeItem;
@end

@interface ListView (Resizing_private)

- (BOOL)isResizeActivatedAtPoint:(NSPoint)pos;

- (void)beginResizing:(NSEvent *)event;
- (void)resizingUpdated:(NSEvent *)event;
- (void)didEndResizing;
- (void)cancelResizing;

@end
