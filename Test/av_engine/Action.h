//  Created by ideawu on 2019/3/9.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Clip.h"

/** 改变 Action 的属性前，应该将其从 track 中移除。*/
@interface Action : NSObject

@property Clip *clip;
/** Action 开始的时间，相对于 clip 的本地时间 */
@property double stime;
/** Action 结束的时间，相对于clip 的本地时间 */
@property (readonly) double etime;
@property double duration;

/** 全局时间 */
- (double)beginTime;
/** 全局时间 */
- (double)endTime;

@end
