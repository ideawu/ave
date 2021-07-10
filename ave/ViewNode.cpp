//  Created by ideawu on 2/15/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#include "ViewNode.h"

namespace ave{
	using namespace a3d;
	
	ViewNode::ViewNode(){
		_autoplay = true;
		_type = ViewNodeTypeStaticImage;
		_contentNode = new SpriteNode();
		this->addSubnode(_contentNode);
	}
	
	ViewNode::~ViewNode(){
		delete _contentNode;
	}
	
	bool ViewNode::autoplay() const{
		return _autoplay;
	}
	
	void ViewNode::autoplay(bool autoplay){
		_autoplay = autoplay;
	}
	
	ViewNodeType ViewNode::type() const{
		return _type;
	}
	
	void ViewNode::type(ViewNodeType type){
		_type = type;
	}
	
	SpriteNode* ViewNode::content() const{
		return _contentNode;
	}
	
	float ViewNode::originWidth() const{
		return _contentNode->width();
	}
	
	float ViewNode::originHeight() const{
		return _contentNode->height();
	}
	
	float ViewNode::contentWidth() const{
		return _contentNode->width() * _contentNode->scale().x;
	}
	
	float ViewNode::contentHeight() const{
		return _contentNode->height() * _contentNode->scale().y;
	}
	
	Frame ViewNode::frame() const{
		return Frame(x()-width()/2, y()-height()/2, width(), height());
	}
	
	Frame ViewNode::bounds() const{
		float w = originWidth();
		float h = originHeight();
		Point3 p0 = Point3(-w/2, -h/2, 0);
		Point3 p1 = Point3(+w/2, -h/2, 0);
		Point3 p2 = Point3(+w/2, +h/2, 0);
		Point3 p3 = Point3(-w/2, +h/2, 0);
		p0 = content()->convertPointToParent(p0);
		p1 = content()->convertPointToParent(p1);
		p2 = content()->convertPointToParent(p2);
		p3 = content()->convertPointToParent(p3);
		float x0 = fmin(fmin(fmin(p0.x, p1.x), p2.x), p3.x);
		float x1 = fmax(fmax(fmax(p0.x, p1.x), p2.x), p3.x);
		float y0 = fmin(fmin(fmin(p0.y, p1.y), p2.y), p3.y);
		float y1 = fmax(fmax(fmax(p0.y, p1.y), p2.y), p3.y);
		return Frame(x0, y0, x1-x0, y1-y0);
	}
	
	float ViewNode::xLeft() const{
		float cx = this->x() + bounds().left();
		float x = frame().left();
		return fmin(x, cx);
	}
	
	float ViewNode::xRight() const{
		float cx = this->x() + bounds().right();
		float x = frame().right();
		return fmax(x, cx);
	}
	
	//float ViewNode::xLeft() const{
	//	float cx = (this->x() + content()->x()) - bounds().width/2;
	//	float x = this->x() - width()/2;
	//	return fmin(x, cx);
	//}
	//
	//float ViewNode::xRight() const{
	//	float cx = (this->x() + content()->x()) + bounds().width/2;
	//	float x = this->x() + width()/2;
	//	return fmax(x, cx);
	//}
	
	void ViewNode::resize(float nw, float nh){
		if(nw * nh == 0){
			return;
		}
		bool isScaled = this->isContentScaled();
		bool isOverflow = this->isContentOverflow();
		bool isFill = this->isContentFill();
		
		this->width(nw);
		this->height(nh);
		
		if(content()->x() == 0){
			if(this->isContentScaled()){
				if(isScaled && isFill && !this->isContentFill()){
					this->setContentToFill();
				}
			}else{
				if(!isOverflow && this->isContentOverflow()){
					this->setContentToBestSize();
				}else if(isFill && !this->isContentFill()){
					this->setContentToBestSize();
				}
			}
		}
	}
	
	bool ViewNode::isContentCentered() const{
		return (content()->x() == 0 && content()->y() == 0);
	}
	
	bool ViewNode::isContentFill() const{
		float gap = 1;
		if(fabs(width() - bounds().width) < gap || fabs(height() - bounds().height) < gap){
			return true;
		}else{
			return false;
		}
	}
	
	bool ViewNode::isContentOverflow() const{
		float gap = -1;
		if(width() - bounds().width < gap || height() - bounds().height < gap){
			return true;
		}else{
			return false;
		}
	}
	
	bool ViewNode::isContentScaled() const{
		float gap = 1;
		if(contentWidth() - originWidth() > gap || contentHeight() - originHeight() > gap){
			return true;
		}else{
			return false;
		}
	}
	
	float ViewNode::zoom() const{
		float ow = originWidth();
		float oh = originHeight();
		if(ow == 0 || oh == 0){
			return 1;
		}
		return contentWidth() / ow;
	}
	
	void ViewNode::zoom(float zoom){
		zoomAt(zoom, Point3());
	}
	
	void ViewNode::zoomAt(float zoom, const Point3 &pos){
		Node *content = this->content();
		Point3 focus = content->convertPointFromParent(pos);
		//	log_debug("%.2f %.2f", content->x(), content->y());
		//	log_debug("%.2f %.2f => %.2f %.2f", pos.x, pos.y, focus.x, focus.y);
		content->move(focus.x, focus.y, 0);
		content->scaleTo(zoom);
		content->move(-focus.x, -focus.y, 0);
		
		float autodock = 1;
		if(fabs(originWidth() - contentWidth()) < autodock || fabs(originHeight() - contentHeight()) < autodock){
			content->scaleTo(1);
		}
	}
	
	void ViewNode::setContentToOrigin(){
		this->zoom(1);
	}
	
	void ViewNode::setContentToBestSize(){
		float ow = bounds().width / this->zoom();
		float oh = bounds().height / this->zoom();
		//	float ow = originWidth();
		//	float oh = originHeight();
		if(ow == 0 || oh == 0){
			return;
		}
		float fw = this->width();
		float fh = this->height();
		float zoom;
		if(fw/fh > ow/oh){
			zoom = fmin(fh, oh) / oh;
		}else{
			zoom = fmin(fw, ow) / ow;
		}
		this->zoom(zoom);
	}
	
	void ViewNode::setContentToFill(){
		float ow = bounds().width / this->zoom();
		float oh = bounds().height / this->zoom();
		//	float ow = originWidth();
		//	float oh = originHeight();
		if(ow == 0 || oh == 0){
			return;
		}
		float fw = this->width();
		float fh = this->height();
		float zoom;
		if(fw/fh > ow/oh){
			zoom = fh / oh;
		}else{
			zoom = fw / ow;
		}
		this->zoom(zoom);
	}
	
	void ViewNode::setContentToFullFill(){
		float ow = bounds().width / this->zoom();
		float oh = bounds().height / this->zoom();
		//	float ow = originWidth();
		//	float oh = originHeight();
		if(ow == 0 || oh == 0){
			return;
		}
		float fw = this->width();
		float fh = this->height();
		float zoom;
		if(fw/fh > ow/oh){
			zoom = fw / ow;
		}else{
			zoom = fh / oh;
		}
		this->zoom(zoom);
	}
	

}; // end namespace
