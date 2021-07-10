//  Created by ideawu on 3/7/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "ListViewItem.h"
#import "ListView.h"
#import "ClipView.h"
#import "TransitionView.h"
#import "Asset.h"

@class TrackView;

@protocol TrackViewDelegate <NSObject>
@required
@optional
- (void)trackView:(TrackView *)trackView didRemoveClipView:(ClipView *)clipView;
- (void)trackView:(TrackView *)trackView didRemoveTransitionView:(ClipView *)clipView;
@end

@interface TrackView : ListView

@property Track *track;

- (BOOL)canInsertTransitionViewAtIndex:(NSUInteger)index;

- (void)insertClipView:(ClipView *)cv atIndex:(NSUInteger)index;
- (void)insertTransitionView:(TransitionView *)tv atIndex:(NSUInteger)index;

@end
