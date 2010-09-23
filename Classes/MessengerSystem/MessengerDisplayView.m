//
//  MessengerDisplayView.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/20.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerDisplayView.h"
#import "GlyphTable.h"

#define NSLog( m, args... )

@implementation MessengerDisplayView


- (id)initWithMessengerDisplayFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
    }
    return self;
}


/**
 辞書を受け取り自己の描画リストを更新する
 */
- (void) updateDrawList:(NSMutableDictionary * )draw andConnectionList:(NSMutableDictionary * )connect {
	
	[drawList autorelease];
	drawList = [draw copy];//ポインタの更新
	NSLog(@"drawList_%@", drawList);
	
	
	[connectionList autorelease];//コネクションの更新
	connectionList = [connect copy];
	
	NSLog(@"connectionList_%@", connectionList);
	
	
	NSLog(@"描画_アップデート");
	[self setNeedsDisplay];
}



/**
 描画メソッドをオーバーライド、描画命令に併せて描く。
 */
- (void)drawRect:(CGRect)rect {

	NSLog(@"描画中");
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetGrayFillColor(context, 0., 1);
	CGContextFillRect(context, [self bounds]);//背景
	
	//背景描画
	CGContextSetGrayFillColor(context, 1., 0.5);
	CGContextFillRect(context, [self bounds]);//背景
	
	
	
	//オブジェクトを描く
	for (id key in drawList) {
		
		
		UIButton * b = [drawList valueForKey:key];
		CGRect bRect = CGRectMake(b.frame.origin.x, b.frame.origin.y, b.frame.size.width, b.frame.size.height);
		
		CGContextSetLineWidth(context, 6.0);
		CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.3);//状態によって色を変える
		CGContextStrokeEllipseInRect(context, bRect);
		CGContextFillEllipseInRect(context, CGRectMake(b.center.x-6, b.center.y-6, 12, 12));
		
		
		//名前を書く
		[GlyphTable drawString:context string:key withFont:@"HiraKakuProN-W3" fontSize:20 
						   atX:b.frame.origin.x atY:b.frame.origin.y];
		
		//ラインを引く
		for (id connectionKey in connectionList) {
			if ([key isEqualToString:connectionKey]) {//一致するキーのラインを描く
				NSArray * positionArray = [connectionList valueForKey:key];
				
				float sx = [[positionArray objectAtIndex:0] floatValue];
				float sy = [[positionArray objectAtIndex:1] floatValue];

				float ex = [[positionArray objectAtIndex:2] floatValue];
				float ey = [[positionArray objectAtIndex:3] floatValue];

				
				lineFromTo(context, CGPointMake(sx,sy), CGPointMake(ex, ey));
			}
		}
	}
}


void lineFromTo(CGContextRef context, CGPoint start, CGPoint end) {
	CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.3);//状態によって色を変える
	
	CGPoint p [2];
	p[0] = start;
	p[1] = end;
	CGContextStrokeLineSegments(context, p, 2);
	
}


- (void)dealloc {
    [super dealloc];
}


@end
