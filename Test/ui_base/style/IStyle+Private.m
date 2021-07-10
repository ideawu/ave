//  Created by ideawu on 3/11/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "IStyle+Private.h"

@implementation IStyle (Private)

- (BOOL)borderNone{
	return self.borderLeft.width == 0 && self.borderRight.width == 0 && self.borderTop.width == 0 && self.borderBottom.width == 0;
}

@end
