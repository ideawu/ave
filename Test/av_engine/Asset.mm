//  Created by ideawu on 3/8/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#import "Asset.h"
#import "Clip.h"
#import "Transition.h"
#include "a3d/a3d.h"
#include <vector>

@interface Asset(){
	a3d::Scene *_scene;
	std::vector<a3d::SpriteNode *> _nodes;
}
@property NSMutableArray<Track *> *tracks;
@end

@implementation Asset

- (void)debug{
	for(Track *t in _tracks){
		[t debug];
	}
}

- (id)initWidth:(int)width height:(int)height{
	self = [super init];
	_width = width;
	_height = height;
	
	_tracks = [[NSMutableArray alloc] init];

	a3d::Context *context = a3d::Context::create();
	a3d::Drawable *drawable = a3d::Drawable::create(self.width, self.height, 0);
	_scene = a3d::Scene::createWith(context, drawable);
	// a3d::Scene 默认是透明背景，但对于视频来，透明颜色将导致编码器特殊处理，
	// 所以，每一帧视频图像必须先用颜色填充整个背景。
	_scene->backgroundColor(a3d::Color::white());

	return self;
}

- (void)dealloc{
	log_debug(@"%s", __func__);
}

- (double)duration{
	double duration = 0;
	for(Track *track in _tracks){
		duration = MAX(duration, track.duration);
	}
	return duration;
}

- (void)addTrack:(Track *)track{
	[_tracks addObject:track];
}

- (CGImageRef)CGImage{
	_scene->context()->makeCurrent();
	return _scene->drawable()->bitmap()->CGImage();
}

- (void)renderAtTime:(double)time callback:(void (^)(void))callback{
	time = TRIM_TIME(time);
	NSMutableArray *clips = [[NSMutableArray alloc] init];
	for(Track *track in _tracks){
		for(Clip *clip in track.clips){
			if(clip.beginTime <= time && clip.endTime > time){
				[clips addObject:clip];
			}
		}
	}

	_scene->context()->makeCurrent();
	_scene->removeAllNodes();

	for(int i=0; i<_nodes.size(); i++){
		delete _nodes[i];
	}
	_nodes.clear();
	
	for(Clip *clip in clips){
		a3d::SpriteNode *node = new a3d::SpriteNode();
		node->updateAtTime(clip.beginTime); // 初始化时钟
		
		_scene->layer(clip.track.layer);
		_scene->addNode(node);
		_nodes.push_back(node);

		const char *filename = [clip.file cStringUsingEncoding:NSUTF8StringEncoding];
		a3d::ImageSprite *sprite = a3d::ImageSprite::createFromFile(filename);
		node->sprite(sprite);
		node->size(_width, _height, 0);
		
		{
			Transition *t = [clip.track transitionBeforeClip:clip];
			if(t){
				node->position(_width, 0, 0);
				Action *action = t.nextAction;

				a3d::Animate *animate = a3d::Animate::position(0, 0, 0);
				animate->beginTime(action.beginTime);
				animate->duration(action.duration);
				animate->disposable(false);
				node->runAnimation(animate);
//				log_debug(@"%f %f", animate->beginTime(), animate->beginTime() + animate->duration());
			}
		}
		{
			Transition *t = [clip.track transitionAfterClip:clip];
			if(t){
				Action *action = t.prevAction;
				
				a3d::Animate *animate = a3d::Animate::position(-_width, 0, 0);
				animate->beginTime(action.beginTime);
				animate->duration(action.duration);
				animate->disposable(false);
				node->runAnimation(animate);
//				log_debug(@"%f %f", animate->beginTime(), animate->beginTime() + animate->duration());
			}
		}
//		log_debug(@"render %@, time range: (%.3f, %.3f)", clip.file.lastPathComponent, clip.beginTime, clip.endTime);
	}

	_scene->view3D();
	_scene->renderAtTime(time);
	callback();
}

@end
