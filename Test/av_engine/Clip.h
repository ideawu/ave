//  Created by ideawu on 3/8/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TIME_PRECISION 1000.0
#define TRIM_TIME(t)   (((round)((t) * TIME_PRECISION)) / TIME_PRECISION)

@class Track;

/**
 Clip 占据的时间区间是 (beginTime, endTime)，不包含 beginTime，但播放时，
 从 beginTime 处开始播放，也即包含 beginTime，这样可以避免 time=0 时无画面的情况。
 */
@interface Clip : NSObject<NSCoding>

/** 注意：修改 clip 的时间属性前，应该将其从 track 中移除！ */
@property (weak) Track *track;

/** 只保留 0.001 精度。 */
@property double beginTime;
/** 只保留 0.001 精度。 */
@property (readonly) double endTime;
/** 只保留 0.001 精度。 */
@property double duration;

@property NSString *file;

@end
