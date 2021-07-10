//  Created by ideawu on 2/15/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "AVEClip.h"

@implementation AVEClip

- (id)init{
	self = [super init];
	_node = new ave::ViewNode();
	return self;
}

- (id)initWithImageFile:(NSString *)file{
	self = [self init];
	self.file = file;
	
	// generate clip info
	if([file.pathExtension.lowercaseString isEqualToString:@"gif"]){
		a3d::ImageSprite *sprite = a3d::ImageSprite::createFromFile([file cStringUsingEncoding:NSUTF8StringEncoding]);
		if(sprite){
			self.duration = sprite->duration();
		}
		delete sprite;
	}
	
	return self;
}

- (void)dealloc{
	delete _node;
}

- (double)endTime{
	return self.beginTime + self.duration;
}

@end
