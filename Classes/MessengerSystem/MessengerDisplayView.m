//
//  MessengerDisplayView.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/20.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerDisplayView.h"


@implementation MessengerDisplayView


- (id)initWithMessengerDisplayFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


/**
 辞書を受け取り自己の描画リストを更新する
 */
- (void) setDrawDict:(NSMutableDictionary * )dict {
	if (drawDict) {
		[drawDict release];
	} 
	drawDict = [dict copy];//ポインタの更新
	[self setNeedsDisplay];
}


/**
 描画メソッドをオーバーライド、描画命令に併せて描く。
 */
- (void)drawRect:(CGRect)rect {
	NSLog(@"描画中");
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetGrayFillColor(context, 1., 1.0);
    CGContextFillRect(context, [self bounds]);
	
	for (id key in drawDict) {
		
	}
	
	
}





- (void)dealloc {
    [super dealloc];
}


@end
