//  Created by ideawu on 3/4/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListView.h"

@protocol ListViewResizingDelegate <NSObject>
@required
- (BOOL)listView:(ListView *)listView canResizeItem:(ListViewItem *)item toSize:(NSSize)size;
- (void)listView:(ListView *)listView didEndResizeItem:(ListViewItem *)item;

@optional
- (void)listView:(ListView *)listView updatedResizeItem:(ListViewItem *)item;
@end

@interface ListView (Resize)

- (void)allowResizing:(BOOL)allow;

@end
