//  Created by ideawu on 2/15/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "VideoAssetClip.h"

@implementation VideoAssetClip

- (id)init{
	self = [super init];
	_node = new ave::ViewNode();
	return self;
}

- (void)dealloc{
	delete _node;
}

- (double)endTime{
	return self.beginTime + self.duration;
}

@end
