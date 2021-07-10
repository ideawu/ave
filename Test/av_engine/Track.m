//  Created by ideawu on 2019/3/9.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "Track.h"

@interface Track()
@property NSMutableArray<Clip *> *clips;
@property NSMutableArray<Transition *> *transitions;
@end

@implementation Track

- (void)debug{
	log_debug(@"track duration: %f", self.duration);
	for(Clip *clip in self.clips){
		log_debug(@" (%7.4f, %7.4f) %@", clip.beginTime, clip.endTime, clip.file.lastPathComponent);
	}
	for(Transition *t in self.transitions){
		log_debug(@" (%7.4f, %7.4f) gap: %6.4f prevAction: (%7.4f, %7.4f) nextAction: (%7.4f, %7.4f)",
				  t.beginTime, t.endTime,
				  t.gapDuration,
				  t.prevAction.beginTime, t.prevAction.endTime,
				  t.nextAction.beginTime, t.nextAction.endTime);
	}
}

- (id)init {
	self = [super init];
	_clips = [[NSMutableArray alloc] init];
	_transitions = [[NSMutableArray alloc] init];
	return self;
}

- (double)duration{
	if(_clips.count == 0){
		return 0;
	}else{
		return _clips.lastObject.endTime;
	}
}

#pragma mark - clip operation

- (void)sortClips{
	[_clips sortUsingComparator:^NSComparisonResult(Clip *a, Clip *b) {
		if(a.beginTime == b.beginTime){
			return NSOrderedSame;
		}else if(a.beginTime < b.beginTime){
			return NSOrderedAscending;
		}else{
			return NSOrderedDescending;
		}
	}];
}

- (Clip *)clipAtTime:(double)time{
	for(Clip *c in _clips){
		if(time > c.beginTime && time < c.endTime){
			return c;
		}
	}
	return nil;
}

- (Clip *)clipBeforeTime:(double)time{
	Clip *ret = nil;
	for(Clip *c in _clips){
		if(c.endTime <= time){
			ret = c;
		}else{
			break;
		}
	}
	return ret;
}

- (Clip *)clipAfterTime:(double)time{
	for(Clip *c in _clips){
		if(c.beginTime >= time){
			return c;
		}
	}
	return nil;
}

- (BOOL)canInsertClipAtTime:(double)time{
	if([self clipAtTime:time]){
//		Clip *c = [self clipAtTime:time];
//		log_debug(@"%.10f %.10f %.10f", time, c.beginTime, c.endTime);
//		log_debug(@"   %d %d", (time > c.beginTime), (time < c.endTime));
		return NO;
	}
	Clip *clip;
	clip = [self clipBeforeTime:time];
	if(clip && [self transitionAfterClip:clip]){
		return NO;
	}
	clip = [self clipAfterTime:time];
	if(clip && [self transitionBeforeClip:clip]){
		return NO;
	}
	return YES;
}

- (void)insertClip:(Clip *)clip{
	for(Clip *c in _clips){
		if(c.beginTime >= clip.beginTime){
			c.beginTime += clip.duration;
		}
	}
	
	clip.track = self;
	[_clips addObject:clip];
	[self sortClips];
//	log_debug(@"%f %f %f %f", self.duration, clip.beginTime, clip.duration, clip.endTime);
}

- (void)removeClip:(Clip *)clip{
	[self removeTransitionsAroundClip:clip];
	clip.track = nil;
	[_clips removeObject:clip];

	for(Clip *c in _clips){
		if(c.beginTime > clip.beginTime){
			c.beginTime -= clip.duration;
		}
	}
}

#pragma mark - transition operation

- (void)sortTransitions{
	[_transitions sortUsingComparator:^NSComparisonResult(Transition *a, Transition *b) {
		if(a.beginTime == b.beginTime){
			return NSOrderedSame;
		}else if(a.beginTime < b.beginTime){
			return NSOrderedAscending;
		}else{
			return NSOrderedDescending;
		}
	}];
}

- (Transition *)transitionBeforeClip:(Clip *)clip{
	for(Transition *t in _transitions){
		if(t.nextClip == clip){
			return t;
		}
	}
	return nil;
}

- (Transition *)transitionAfterClip:(Clip *)clip{
	for(Transition *t in _transitions){
		if(t.prevClip == clip){
			return t;
		}
	}
	return nil;
}

- (BOOL)canAddTransitionBeforeClip:(Clip *)clip{
	return [self transitionBeforeClip:clip] == nil;
}

- (BOOL)canAddTransitionAfterClip:(Clip *)clip{
	return [self transitionAfterClip:clip] == nil;
}

- (BOOL)canAddTransitionAfterClip:(Clip *)first andBeforeClip:(Clip *)second{
	return [self canAddTransitionAfterClip:first] && [self canAddTransitionBeforeClip:second];
}

- (void)addTransition:(Transition *)transition{
	if(transition.nextClip){
		for(Clip *c in _clips){
			if(c.beginTime >= transition.nextClip.beginTime){
				c.beginTime += transition.gapDuration;
			}
		}
	}
	transition.track = self;
	[_transitions addObject:transition];
	[self sortTransitions];
}

- (void)removeTransition:(Transition *)transition{
	if(transition.nextClip){
		for(Clip *c in _clips){
			if(c.beginTime >= transition.nextClip.beginTime){
				c.beginTime -= transition.gapDuration;
			}
		}
	}
	transition.track = nil;
	[_transitions removeObject:transition];
	[self sortTransitions];
}

- (void)removeTransitionsAroundClip:(Clip *)clip{
	Transition *t0 = [self transitionBeforeClip:clip];
	Transition *t1 = [self transitionAfterClip:clip];
	if(t0){
		[self removeTransition:t0];
	}
	if(t1){
		[self removeTransition:t1];
	}
}

@end
