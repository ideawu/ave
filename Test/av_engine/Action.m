//  Created by ideawu on 2019/3/9.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "Action.h"

@implementation Action

- (double)beginTime{
	if(!_clip){
		return 0;
	}
	return _stime + _clip.beginTime;
}

- (double)endTime{
	if(!_clip){
		return 0;
	}
	return self.beginTime + self.duration;
}

@end
