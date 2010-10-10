//
//  MessengerDisplayView.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/20.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NUM_OF_COLOR (8)//iOSに用意されているデフォルトカラー。システムの指定カラーの中から先頭８色を使用する。


/**
 親となるコントローラから、ボタンをセットされる対象のUIView。
 ボタンの下敷きに情報、ラインを描く。
 
 */
@interface MessengerDisplayView : UIView {
	
	id m_controllerId;
	
	int m_colorIndex;
	
	NSMutableDictionary * m_drawList;
	NSMutableDictionary * m_connectionList;
	
	
	UIEvent * m_pinchEvent;
	
	CGFloat	m_lastPinchDist;//2点間の距離
	CGPoint m_lastPoint;//1点の位置
	
}


- (void) setControllerDelegate:(id)contID;

- (void) updateDrawList:(NSMutableDictionary * )draw andConnectionList:(NSMutableDictionary * )connect;



- (id)initWithMessengerDisplayFrame:(CGRect)frame;

- (void) setAnimation;
- (void) commitAnimation;

void lineFromTo(CGContextRef context, CGPoint start, CGPoint end, UIColor * color, float width, float alphaScale);


float linePrmGetA(float cx, float cy, float px, float py);
float linePrmGetB(float cx, float cy, float px, float py);
float linePrmGetC(float cx, float cy, float px, float py);
CGPoint lineCrclCrsPt (float circleX, float circleY, float circleR, 
					   float cx, float cy,
					   float px,float py, 
					   float nX,float nY);


@end
