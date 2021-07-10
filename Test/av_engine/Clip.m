//  Created by ideawu on 3/8/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "Clip.h"

@interface Clip(){
	double _beginTime;
	double _duration;
}
@end

@implementation Clip

- (id)init{
	self = [super init];
	_beginTime = 0;
	_duration = 0;
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
	NSArray *vals = @[self.file, @(self.duration)];
	[aCoder encodeRootObject:vals];
}

- (id)initWithCoder:(NSCoder *)aCoder{
	self = [self init];
	NSArray *vals = (NSArray *)[aCoder decodeObject];
	self.file = (NSString *)[vals objectAtIndex:0];
	self.duration = [(NSNumber *)[vals objectAtIndex:1] floatValue];
	return self;
}

- (double)beginTime{
	return _beginTime;
}

- (void)setBeginTime:(double)beginTime{
	_beginTime = TRIM_TIME(beginTime);
}

- (double)endTime{
	return TRIM_TIME(self.beginTime + self.duration);
}

- (double)duration{
	return _duration;
}

- (void)setDuration:(double)duration{
	_duration = TRIM_TIME(duration);
}

@end
