//  Created by ideawu on 2/15/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoAssetClip.h"

@interface VideoAsset : NSObject

@property (readonly) int width;
@property (readonly) int height;
@property (readonly) double duration;
// 获取当前已渲染的内容
@property(nonatomic, readonly) CGImageRef CGImage;

- (id)init NS_UNAVAILABLE;
- (id)initWidth:(int)width height:(int)height;

- (NSArray *)clips;
- (void)addClip:(VideoAssetClip *)clip;

- (void)renderAtTime:(double)time callback:(void (^)(void))callback;

@end
