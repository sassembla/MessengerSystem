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
        m_scale = 1.0;
		
		
    }
    return self;
}


/**
 辞書を受け取り自己の描画リストを更新する
 */
- (void) updateDrawList:(NSMutableDictionary * )draw andConnectionList:(NSMutableDictionary * )connect {
	
	[m_drawList autorelease];
	m_drawList = [draw copy];//ポインタの更新
	
	
	[m_connectionList autorelease];//コネクションの更新
	m_connectionList = [connect copy];
	
	
	
	NSLog(@"描画_アップデート");
	[self setNeedsDisplay];
}

- (void) setScale {
	//スケール タッチが動いた/画面から離れた時の２点間の距離
	m_scale = m_scale;
}


- (float) getScale {
	return m_scale;
}





/**
 描画メソッドをオーバーライド、描画命令に併せて描く。
 */
- (void)drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetGrayFillColor(context, 0., 1);
	CGContextFillRect(context, [self bounds]);//背景
	
	//背景描画
	CGContextSetGrayFillColor(context, 1., 0.5);
	CGContextFillRect(context, [self bounds]);//背景
	
	int index = (int)rand()%8;//カラー
	
	//オブジェクトを描く
	for (id key in m_drawList) {
		
		
		
		UIButton * b = [m_drawList valueForKey:key];
		CGRect bRect = CGRectMake(b.frame.origin.x, b.frame.origin.y, b.frame.size.width, b.frame.size.height);
		
		CGContextSetLineWidth(context, 6.0);
		CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.3);//状態によって色を変える
		CGContextStrokeEllipseInRect(context, bRect);
		CGContextFillEllipseInRect(context, CGRectMake(b.center.x-6, b.center.y-6, 12, 12));
		
		
		//名前を書く
		[GlyphTable drawString:context string:[key substringToIndex:5] withFont:@"HiraKakuProN-W3" fontSize:20 
						   atX:b.frame.origin.x atY:b.frame.origin.y];
		
		//ラインを引く
		for (id connectionKey in m_connectionList) {
			if ([key isEqualToString:connectionKey]) {//一致するキーのラインを描く
				NSArray * positionArray = [m_connectionList valueForKey:key];
				
				float sx = [[positionArray objectAtIndex:0] floatValue];
				float sy = [[positionArray objectAtIndex:1] floatValue];

				float ex = [[positionArray objectAtIndex:2] floatValue];
				float ey = [[positionArray objectAtIndex:3] floatValue];

//				+ (UIColor *)redColor;        // 1.0, 0.0, 0.0 RGB 
//				+ (UIColor *)greenColor;      // 0.0, 1.0, 0.0 RGB 
//				+ (UIColor *)blueColor;       // 0.0, 0.0, 1.0 RGB 
//				+ (UIColor *)cyanColor;       // 0.0, 1.0, 1.0 RGB 
//				+ (UIColor *)yellowColor;     // 1.0, 1.0, 0.0 RGB 
//				+ (UIColor *)magentaColor;    // 1.0, 0.0, 1.0 RGB 
//				+ (UIColor *)orangeColor;     // 1.0, 0.5, 0.0 RGB 
//				+ (UIColor *)purpleColor;     // 0.5, 0.0, 0.5 RGB 
//				+ (UIColor *)brownColor;      // 0.6, 0.4, 0.2 RGB 
				
				UIColor * col;
				switch (index) {
					case 0:
						col = [UIColor redColor];
						break;
						
					case 1:
						col = [UIColor greenColor];
						break;
						
					case 2:
						col = [UIColor blueColor];
						break;
						
					case 3:
						col = [UIColor cyanColor];
						break;
						
					case 4:
						col = [UIColor yellowColor];
						break;
						
					case 5:
						col = [UIColor magentaColor];
						break;
						
					case 6:
						col = [UIColor orangeColor];
						break;
						
					case 7:
						col = [UIColor purpleColor];
						break;
						
					default:
						col = [UIColor brownColor];
						break;
				}
				
				lineFromTo(context, CGPointMake(sx,sy), CGPointMake(ex, ey), col);
				//pointTo();
				[col release];
				
				index = (index + 1)%8;
			}
		}
	}
}

/**
 ラインを描画するメソッド
 */
void lineFromTo(CGContextRef context, CGPoint start, CGPoint end, UIColor * color) {
	CGContextSetLineWidth(context, 3.5);
	
	CGContextSetStrokeColorWithColor(context, CGColorCreateCopyWithAlpha([color CGColor], 0.2));
	
	CGPoint p [2];
	p[0] = start;
	p[1] = end;
	
	CGContextStrokeLineSegments(context, p, 2);
}



/**
 タッチ開始
 */
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"たっち");
	for (UITouch * touch in touches) {
		CGPoint p = [touch locationInView:self];
		if (2 <= [touch tapCount]) {
			//[messenger sendMessage:TOUCH_DOUBLETAPPED,[NSNumber numberWithFloat:p.x],[NSNumber numberWithFloat:p.y],nil];
			return;
		}
		
		//[messenger sendMessage:TOUCHES_BEGAN,[NSNumber numberWithFloat:p.x],[NSNumber numberWithFloat:p.y],nil];
	}
	
}



/**
 タッチの移動
 */
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"たっち移動");
	for (UITouch * touch in touches) {
		CGPoint p = [touch locationInView:self];
		//[messenger sendMessage:TOUCHES_MOVED,[NSNumber numberWithFloat:p.x],[NSNumber numberWithFloat:p.y],nil];
	}
}



/**
 タッチの終了
 */
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"たっち終了");
	for (UITouch * touch in touches) {
		CGPoint p = [touch locationInView:self];
		//[messenger sendMessage:TOUCHES_ENDED,[NSNumber numberWithFloat:p.x],[NSNumber numberWithFloat:p.y],nil];
	}
}




- (void)dealloc {
    [super dealloc];
}


@end
