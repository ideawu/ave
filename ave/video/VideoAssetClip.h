//  Created by ideawu on 2/15/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ViewNode.h"

@interface VideoAssetClip : NSObject

@property NSString *file;
@property int layer;
@property double beginTime;
@property (readonly) double endTime;
@property double duration;

// 可取值 bestsize|fullfill，默认 bestsize
@property NSString *scale;

// TODO: 不应该暴露此属性，应该根据属性配置，在内部生成 node
@property ave::ViewNode *node;

@end
