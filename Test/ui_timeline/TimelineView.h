//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ListView.h"
#import "TrackView.h"

@interface TimelineView : IView

@property (readonly) IView *previewMarker;
//@property (readonly) LineView *playPointMarker;

- (TrackView *)currentTrackView;

- (void)addTrackView:(TrackView *)tv;

@end
