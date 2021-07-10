//  Created by ideawu on 3/5/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "AVETrack.h"
#import "AVEAsset.h"

@interface AVETrack(){
	NSMutableArray *_clips;
}
@property NSMutableArray *transitions;
@end


@implementation AVETrack

- (id)init{
	self = [super init];
	_clips = [[NSMutableArray alloc] init];
	_transitions = [[NSMutableArray alloc] init];
	return self;
}

- (void)dealloc{
	log_debug(@"%s", __func__);
	[_clips removeAllObjects];
	[_transitions removeAllObjects];
}

- (double)duration{
	if(_clips.count == 0){
		return 0;
	}else{
		AVEClip *clip = _clips.lastObject;
		return clip.endTime;
	}
}

- (NSArray *)clips{
	return _clips;
}

- (void)sortClips{
	[_clips sortUsingComparator:^NSComparisonResult(AVEClip *a, AVEClip *b) {
		if(a.beginTime == b.beginTime){
			return NSOrderedSame;
		}else if(a.beginTime < b.beginTime){
			return NSOrderedAscending;
		}else{
			return NSOrderedDescending;
		}
	}];
}

- (NSUInteger)indexOfClip:(AVEClip *)clip{
	return [_clips indexOfObject:clip];
}

- (AVEClip *)clipAtIndex:(NSUInteger)index{
	if(index >= _clips.count){
		return nil;
	}
	return [_clips objectAtIndex:index];
}

- (void)addClip:(AVEClip *)clip{
	[self insertClip:clip atIndex:_clips.count];
}

- (void)insertClip:(AVEClip *)clip atIndex:(NSUInteger)index{
	if(index > _clips.count){
		index = _clips.count;
	}
	
	if(index < _clips.count){
		AVEClip *replace = [_clips objectAtIndex:index];
		clip.beginTime = replace.beginTime;
	}else{
		clip.beginTime = self.duration;
	}
	
	[_clips insertObject:clip atIndex:index];
	
	[self incrClipsBeginTimeBy:clip.duration fromIndex:index+1];
	[self sortClips];
}

- (void)removeClipAtIndex:(NSUInteger)index{
	if(index >= _clips.count){
		return;
	}
	
	AVEClip *clip = [_clips objectAtIndex:index];
	[_clips removeObjectAtIndex:index];
	
	[self incrClipsBeginTimeBy:-clip.duration fromIndex:index];
	[self sortClips];
}

- (void)incrClipsBeginTimeBy:(double)dt fromIndex:(NSUInteger)index{
	for(NSUInteger i=index; i<_clips.count; i++){
		AVEClip *c = [_clips objectAtIndex:i];
		c.beginTime += dt;
	}
}

#pragma mark - transitions

- (AVETransition *)transitionAtIndex:(NSUInteger)index{
	AVEClip *prev = [self clipAtIndex:index-1];
	AVEClip *next = [self clipAtIndex:index];
	if(!prev && !next){
		return nil;
	}
	for(AVETransition *t in _transitions){
		if(t.prevAction.clip == prev && t.nextAction.clip == next){
			return t;
		}
	}
	return nil;
}

- (void)insertTransition:(AVETransition *)transition atIndex:(NSUInteger)index{
	AVEClip *prev = [self clipAtIndex:index-1];
	AVEClip *next = [self clipAtIndex:index];
	if(!prev && !next){
		return;
	}
	
	transition.prevAction.clip = prev;
	transition.nextAction.clip = next;

	[self removeTransitionAtIndex:index];
	[_transitions addObject:transition];
	
	if(next){
		[self incrClipsBeginTimeBy:transition.gapDuration fromIndex:index];
	}
}

- (void)removeTransitionAtIndex:(NSUInteger)index{
	AVETransition *old = [self transitionAtIndex:index];
	if(old){
		[self incrClipsBeginTimeBy:-old.gapDuration fromIndex:index];
		[_transitions removeObject:old];
	}
}

@end
