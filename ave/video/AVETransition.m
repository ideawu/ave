//  Created by ideawu on 3/6/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "AVETransition.h"

@implementation AVETransition

- (id)init{
	self = [super init];
	return self;
}

- (id)initWithGapDuration:(double)gapDuration{
	self = [self init];
	_gapDuration = gapDuration;
	return self;
}

- (double)duration{
	double ret = 0;
	if(_prevAction){
		ret += _prevAction.duration;
	}
	if(_nextAction){
		ret += _nextAction.duration;
	}
	ret += _gapDuration;
	return ret;
}

@end
