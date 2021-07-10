//  Created by ideawu on 2/15/19.
//  Copyright © 2019 ideawu. All rights reserved.
//

#ifndef AVE_ViewNode_hpp
#define AVE_ViewNode_hpp

#include <a3d/a3d.h>

namespace ave{
	typedef enum{
		ViewNodeTypeStaticImage,
		ViewNodeTypeAnimatedImage,
		ViewNodeTypeSVGImage,
	}ViewNodeType;

	class ViewNode : public a3d::Node
	{
	public:
		ViewNode();
		~ViewNode();
		
		bool autoplay() const;
		void autoplay(bool autoplay);
		
		ViewNodeType type() const;
		void type(ViewNodeType type);
		
		a3d::SpriteNode* content() const;
		
		float originWidth() const;
		float originHeight() const;
		// 原图缩放后的宽度
		float contentWidth() const;
		float contentHeight() const;
		
		// 视口的矩形区域
		a3d::Frame frame() const;
		// 内容占用的矩形区域(在frame空间里)，偏转一定角度后，占用的矩形会扩大
		a3d::Frame bounds() const;
		
		// frame+bounds占用整个矩形, 在节点空间
		float xLeft() const;
		float xRight() const;
		
		void resize(float w, float h);
		
		void setContentToOrigin();
		void setContentToFill();
		void setContentToBestSize();
		void setContentToFullFill();
		
		bool isContentCentered() const;
		bool isContentFill() const;
		bool isContentScaled() const;
		bool isContentOverflow() const;
		
		float zoom() const;
		void zoom(float zoom);
		void zoomAt(float zoom, const a3d::Point3 &pos);
		
	private:
		ViewNode(const ViewNode &d);
		ViewNode& operator =(const ViewNode& d);
		
		bool _autoplay;
		ViewNodeType _type;
		a3d::SpriteNode *_contentNode;
	};

}; // end namespace

#endif /* ViewNode_hpp */
