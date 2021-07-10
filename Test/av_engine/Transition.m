//  Created by ideawu on 3/8/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "Transition.h"

@interface Transition(){
}
@end

@implementation Transition

- (id)init{
	self = [super init];
	_name = @"SlideOutSlideIn";
	_gapDuration = 0;
	_prevAction = [[Action alloc] init];
	_nextAction = [[Action alloc] init];
	_prevAction.duration = 0.5;
	_nextAction.duration = 0.5;
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	NSArray *vals = @[self.name, @(self.gapDuration),
					  @(self.prevAction.duration), @(self.nextAction.duration)];
	[aCoder encodeRootObject:vals];
}

- (id)initWithCoder:(NSCoder *)aCoder{
	self = [self init];
	NSArray *vals = (NSArray *)[aCoder decodeObject];
	self.name = (NSString *)[vals objectAtIndex:0];
	self.gapDuration = [(NSNumber *)[vals objectAtIndex:1] floatValue];
	self.prevAction.duration = [(NSNumber *)[vals objectAtIndex:2] floatValue];
	self.nextAction.duration = [(NSNumber *)[vals objectAtIndex:3] floatValue];
	return self;
}

- (double)beginTime{
	if(_prevAction.clip){
		return _prevAction.beginTime;
	}else{
		return _nextAction.beginTime;
	}
}

- (double)endTime{
	if(_nextAction.clip){
		return _nextAction.endTime;
	}else{
		return _prevAction.endTime;
	}
}

- (double)duration{
	return self.endTime - self.beginTime;
}

- (Clip *)prevClip{
	return _prevAction.clip;
}

- (void)setPrevClip:(Clip *)clip{
	_prevAction.clip = clip;
	if(clip){
		_prevAction.duration = MIN(_prevAction.duration, clip.duration/2);
		_prevAction.stime = clip.duration - _prevAction.duration;
	}
}

- (Clip *)nextClip{
	return _nextAction.clip;
}
- (void)setNextClip:(Clip *)clip{
	_nextAction.clip = clip;
	if(clip){
		// 转场时长不超过 clip 一半
		_nextAction.duration = MIN(_nextAction.duration, clip.duration/2);
		_nextAction.stime = 0;
		// gap 不能让 clip 前移到 0 之前
		_gapDuration = MAX(_gapDuration, -clip.beginTime);
		// gap 不能让前后两个 action 完全包含
		_gapDuration = MAX(_gapDuration, -MIN(_prevAction.duration, _nextAction.duration));
	}
}

@end
