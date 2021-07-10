//  Created by ideawu on 3/6/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVEClip;

@interface AVEAction : NSObject

@property (weak) AVEClip *clip;

/** 相对于 clip 内部时钟。 */
@property double beginTime;
/** Action 起作用的时长。 */
@property double duration;
/** 相对于 clip 内部时钟。 */
@property (readonly) double endTime;

@end
