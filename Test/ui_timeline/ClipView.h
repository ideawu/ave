//  Created by ideawu on 2019/2/27.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ListView.h"
#import "Asset.h"

@class TransitionView;

@interface ClipView : ListViewItem<NSCoding>

@property Clip *clip;

@property NSString *title;
@property double duration;

@end
