//
//  MessengerDisplayView.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/20.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 親となるコントローラから、ボタンをセットされる対象。
 ボタンの下敷きに情報、ラインを描く。
 
 */
@interface MessengerDisplayView : UIView {
	NSMutableDictionary * m_drawList;
	NSMutableDictionary * m_connectionList;
	float m_scale;
}


- (void) updateDrawList:(NSMutableDictionary * )draw andConnectionList:(NSMutableDictionary * )connect;
- (id)initWithMessengerDisplayFrame:(CGRect)frame;

void lineFromTo(CGContextRef context, CGPoint start, CGPoint end, UIColor * color);


/**
 スケール関連
 */
- (void) setScale;
- (float) getScale;



@end
