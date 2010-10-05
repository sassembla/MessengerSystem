//
//  MessengerDisplayView.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/20.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerViewController.h"
#import "MessengerDisplayView.h"
#import "GlyphTable.h"


@implementation MessengerDisplayView


- (id)initWithMessengerDisplayFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		m_colorIndex = (int)rand() % NUM_OF_COLOR;
    }
    return self;
}


/**
 コントローラのIDをセットする
 */
- (void) setControllerDelegate:(id)contID {
	controllerId = contID;
}


/**
 辞書を受け取り自己の描画リストを更新する
 */
- (void) updateDrawList:(NSMutableDictionary * )draw andConnectionList:(NSMutableDictionary * )connect {
	
	[m_drawList autorelease];
	m_drawList = [draw copy];//ポインタの更新
	
	
	[m_connectionList autorelease];//コネクションの更新
	m_connectionList = [connect copy];
	
	
	[self setNeedsDisplay];
}





/**
 描画メソッドをオーバーライド、描画命令に併せて描く。
 */
- (void)drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetGrayFillColor(context, 0., 1);
	CGContextFillRect(context, [self bounds]);//背景
	//この領域に対して、現在のスケールに併せた描画をおこなう、、かなあ。
	
	
	
	
	//背景描画
	CGContextSetGrayFillColor(context, 1., 0.5);
	CGContextFillRect(context, [self bounds]);//背景
	
	
	
	int index = m_colorIndex;//ラインカラー
	
	//オブジェクトを描く
	for (id key in m_drawList) {
		
		
		UIButton * b = [m_drawList valueForKey:key];
		CGRect bRect = CGRectMake(b.frame.origin.x, b.frame.origin.y, b.frame.size.width, b.frame.size.height);
		
		CGContextSetLineWidth(context, 6.0);
		CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.3);//状態によって色を変える
		CGContextSetGrayFillColor(context, 1., 0.5);
		
		CGContextStrokeEllipseInRect(context, bRect);
		CGContextFillEllipseInRect(context, CGRectMake(b.center.x-6, b.center.y-6, 12, 12));
		
		UIColor * textCol = [UIColor whiteColor];
		//名前を書く
		[GlyphTable drawString:context 
						 string:[key substringToIndex:10]
					  withFont:@"HiraKakuProN-W3"
				  withFontSize:12
					 withColor:textCol
						   atX:b.frame.origin.x 
						   atY:b.frame.origin.y];
		
		
		
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
				//傾き、特定の点からの位置
				
				//pointTo();//終点に、子供マークを付ける。文字でOK、
				[col release];
				
				index = (index + 1)%NUM_OF_COLOR;
			}
		}
	}
}

/**
 ラインを描画するメソッド
 αは固定。
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
- (void) touchesBegan:(NSSet * )touches withEvent:(UIEvent * )event {
	
	NSLog(@"touches_%@",[event allTouches]);//なるほど。こうしないとタッチ全体が見れない。
	
	for (UITouch * touch in touches) {
		if (2 <= [touch tapCount]) {
			[controllerId scaleReset];
			return;
		}
	}
	
	
	/**
	 イベントの記録
	 カウントの数確認
	 を行う。
	 */
	if (!pinchEvent) {//イベントの種類ごとに振り分ける事で、排他にできる、、という理由。
		NSArray * t = [[event allTouches] allObjects];//配列化する
		
		if ([[event allTouches] count] == 2){
			pinchEvent = event;//イベントをセットする。のちのち識別するため。この方法は面白い。でも弱点がありそう。
			
			lastPinchDist = fabs([[t objectAtIndex:0] locationInView:self].x - [[t objectAtIndex:1] locationInView:self].x);//開始時の2点間の距離を得る(xのみ)
		} else {
			lastPoint = CGPointMake([[t objectAtIndex:0] locationInView:self].x, [[t objectAtIndex:0] locationInView:self].y);
		}		
	} 
	
	
}



/**
 タッチの移動
 */
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
	if (event == pinchEvent && [[event allTouches] count] == 2) {
		CGFloat thisPinchDist, pinchDiff;//最新の2点間の距離、開始時からの差分
		
		NSArray * t = [[event allTouches] allObjects];//配列化
		thisPinchDist = fabs([[t objectAtIndex:0] locationInView:self].x - [[t objectAtIndex:1] locationInView:self].x);//最新の2点間の距離
		
		pinchDiff = (thisPinchDist - lastPinchDist)*0.01f;//差分
		
		[controllerId setScale:[controllerId getScale]+pinchDiff];
		
		lastPinchDist = thisPinchDist;//更新、、、？
	} else {
		
		//前回の位置からの移動分だけ、worldを動かす。
		NSArray * t = [[event allTouches] allObjects];//配列化
		
		[controllerId moveWorldX:[[t objectAtIndex:0] locationInView:self].x - lastPoint.x withY:[[t objectAtIndex:0] locationInView:self].y - lastPoint.y];
		
		lastPoint = CGPointMake([[t objectAtIndex:0] locationInView:self].x, [[t objectAtIndex:0] locationInView:self].y);
	
	}

	
}



/**
 タッチの終了
 */
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (event == pinchEvent)
	{
		pinchEvent = nil;//イベント削除
		return;
	}
}




- (void)dealloc {
    [super dealloc];
}


@end
