//  Created by ideawu on 3/6/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVEAction.h"

@interface AVETransition : NSObject

@property AVEAction *prevAction;
@property AVEAction *nextAction;

/**
 prev 和 next 之间的空白时间， 当 gapDuration 小于 0 时，表示两个 Action 的时间有重叠。
 */
@property (readonly) double gapDuration;
@property (readonly) double duration;

- (id)initWithGapDuration:(double)gapDuration;

@end
