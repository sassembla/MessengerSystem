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
 親となるコントローラから、ボタンをセットされる対象。
 ボタンの下敷きに情報、ラインを描く。
 
 */
@interface MessengerDisplayView : UIView {
	
	id controllerId;
	
	int m_colorIndex;
	
	NSMutableDictionary * m_drawList;
	NSMutableDictionary * m_connectionList;
	
	UIEvent * pinchEvent;
	
	CGFloat	lastPinchDist;//2点間の距離
	CGPoint lastPoint;//1点の位置
	
}


- (void) setControllerDelegate:(id)contID;

- (void) updateDrawList:(NSMutableDictionary * )draw andConnectionList:(NSMutableDictionary * )connect;
- (id)initWithMessengerDisplayFrame:(CGRect)frame;

void lineFromTo(CGContextRef context, CGPoint start, CGPoint end, UIColor * color);




@end
