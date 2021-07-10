//  Created by ideawu on 3/8/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Action.h"

@class Track;

/** 改变 Transition 的属性前，应该将其从 track 中移除。*/
@interface Transition : NSObject<NSCoding>

/** 注意：修改 transition 的时间属性前，应该将其从 track 中移除！ */
@property (weak) Track *track;

@property NSString *name;

/** 可负数，表示两个 clip 有时间重叠。重叠时 gapDuration 长度必须小于 nextAction.duration。 */
@property double gapDuration;
@property Action *prevAction;
@property Action *nextAction;

- (double)beginTime;
- (double)endTime;
- (double)duration;

- (Clip *)prevClip;
- (void)setPrevClip:(Clip *)clip;
- (Clip *)nextClip;
- (void)setNextClip:(Clip *)clip;

@end
