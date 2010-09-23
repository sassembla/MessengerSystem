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
- (void) updateDrawList:(NSMutableDictionary * )dict {
	[drawDict autorelease];
	drawDict = [dict copy];//ポインタの更新
	NSLog(@"描画_アップデート");
	[self setNeedsDisplay];
}

void addRoundRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
	if (ovalWidth != 0 && ovalHeight != 0) {
		float fw,fh;
		
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextScaleCTM(context, ovalWidth, ovalHeight);
		fw = CGRectGetWidth(rect)/ovalWidth;
		fh = CGRectGetHeight(rect)/ovalHeight;
		CGContextMoveToPoint(context, fw, fh/2);
		
		CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 0.5);	//右上
		CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 0.5);	//左上
		CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 0.5);	//左下
		CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 0.5);	//右下
		
		CGContextClosePath(context);
		CGContextRestoreGState(context);
	} else {
		
	}
}	


/**
 描画メソッドをオーバーライド、描画命令に併せて描く。
 */
- (void)drawRect:(CGRect)rect {

//	NSLog(@"描画中");
//	CGContextRef context = UIGraphicsGetCurrentContext();
//	CGContextSetGrayFillColor(context, 1., 1.0);
//    CGContextFillRect(context, [self bounds]);//背景
//
//	CGContextSetLineWidth(context, 4.0);
//	CGContextBeginPath(context);
//	
//	
//	
//	for (id key in drawDict) {
//		NSLog(@"drawDict_%@",[drawDict valueForKey:key]);
//		{
//			//buttonの位置に、何か。
//			UIButton * b = [drawDict valueForKey:key];
//			NSLog(@"x_%f	y_%f", b.frame.origin.x, b.frame.origin.y);
//			CGRect bRect = CGRectMake(b.frame.origin.x, b.frame.origin.y, b.frame.size.width, b.frame.size.height);
//			
//			
//			addRoundRectToPath(context, bRect, b.frame.origin.x, b.frame.origin.y);
//			
////			[[UIColor colorWithRed:10 green:100 blue:1 alpha:0.5] setFill];
////			[[UIBezierPath bezierPathWithRect:bRect] fill];
//		}
//	}
//	CGContextSetRGBStrokeColor(context, 0,0,0,0.3);
//
//	CGContextDrawPath(context, kCGPathStroke);
	
	
}





- (void)dealloc {
    [super dealloc];
}


@end
