//  Created by ideawu on 3/12/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "IView.h"
#import "ListView.h"

@interface NestedListView : IView

@property (readonly) NSScrollView *scrollView;
@property (readonly) ListView *mainListView;

/** 不包括滚动条 */
@property (readonly) NSSize viewportSize;

- (void)addSubListView:(ListView *)subListView;
- (void)insertSubListView:(ListView *)subListView atIndex:(NSUInteger)index;

@end
