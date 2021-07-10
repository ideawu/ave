//  Created by ideawu on 3/4/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IView.h"

@class ListView;

@interface ListViewItem : IView

@property (weak) ListView *listView;
@property IView *contentView;

@property BOOL selected;
@property BOOL resizable;

@end
