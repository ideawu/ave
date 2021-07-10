//  Created by ideawu on 2/15/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVETrack.h"
#import "AVEClip.h"

@interface AVEAsset : NSObject

@property (readonly) int width;
@property (readonly) int height;
@property (readonly) double duration;
/** 获取当前已渲染的内容，在 render 之后有效。 */
@property(nonatomic, readonly) CGImageRef CGImage;

- (id)init NS_UNAVAILABLE;
- (id)initWidth:(int)width height:(int)height;

- (AVETrack *)track:(NSUInteger)index;

/**
 可能在 main 线程中执行 callback，也可能在当前线程(如果不是 main)中执行 callback。
 取决于图片的类型，某些类型(如 SVG)可能使用 main 线程进行加载。
 */
- (void)renderAtTime:(double)time callback:(void (^)(void))callback;

@end
