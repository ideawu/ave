//  Created by ideawu on 3/11/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "IStyle.h"
#import "IStyleBorder.h"
#import "ICssBlock.h"
#import "ICssDecl.h"

@interface IStyle ()

@property (nonatomic, readonly) CGFloat borderRadius;
@property (nonatomic, readonly) IStyleBorder *borderLeft;
@property (nonatomic, readonly) IStyleBorder *borderRight;
@property (nonatomic, readonly) IStyleBorder *borderTop;
@property (nonatomic, readonly) IStyleBorder *borderBottom;
@end

@interface IStyle (Private)

- (BOOL)borderNone;

@end

