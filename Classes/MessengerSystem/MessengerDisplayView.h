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
	NSMutableDictionary * drawDict;
}
- (void) updateDrawList:(NSMutableDictionary * )dict;
- (id)initWithMessengerDisplayFrame:(CGRect)frame;

@end
