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
#import "MessengerIDGenerator.h"

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
	m_controllerId = contID;
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
	
	
	//背景描画
	CGContextSetGrayFillColor(context, 1., 0.5);
	CGContextFillRect(context, [self bounds]);//背景
	
	
	
	int index = m_colorIndex;//ラインカラー
	
	//オブジェクトを描く
	NSArray * drawKeys = [m_drawList allKeys];
	
	for (int i = 0; i < [drawKeys count]; i++) {
		id key = [drawKeys objectAtIndex:i];
		
		UIButton * b = [m_drawList valueForKey:key];
		CGRect bRect = CGRectMake(b.frame.origin.x, b.frame.origin.y, b.frame.size.width, b.frame.size.height);
		
		CGContextSetLineWidth(context, 6.0);
		CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.3);//状態によって色を変える
		CGContextSetGrayFillColor(context, 1., 0.5);
		
		CGContextStrokeEllipseInRect(context, bRect);//アウトライン
		CGContextFillEllipseInRect(context, CGRectMake(b.center.x-6, b.center.y-6, 12, 12));//矩形内に円を描く
		
		
		UIColor * textCol = [UIColor whiteColor];
		
		//オブジェクトの名前を書く
		
		[GlyphTable drawString:context 
						 string:[key substringToIndex:[key length]-([[MessengerIDGenerator getMID] length]+1)]
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
				
				
				/**
				 親/子のマーク、線の上に出してあげると嬉しい。色で分かる。
				 円上の点を出す。より子供、親に近い方。
				 */
				
				float adjustX = -3, adjustY = +3;
				float r = bRect.size.width/4;
				
				
				
				
				CGPoint cPoint = lineCrclCrsPt(sx,sy,r,	sx,sy,ex,ey,	ex,ey);//子の円と直線との交点で、親に近い方
				
				[GlyphTable drawString:context 
								string:@"c"
							  withFont:@"HiraKakuProN-W3"
						  withFontSize:12
							 withColor:col
								   atX:cPoint.x+adjustX 
								   atY:cPoint.y+adjustY];
				
				
				CGPoint pPoint = lineCrclCrsPt(ex,ey,r,	sx,sy,ex,ey,	sx,sy);//親の円と直線との交点で、子に近い方
				
				[GlyphTable drawString:context 
								string:@"P"
							  withFont:@"HiraKakuProN-W3"
						  withFontSize:12
							 withColor:col
								   atX:pPoint.x+adjustX
								   atY:pPoint.y+adjustY];
				
				
				index = (index + 1)%NUM_OF_COLOR;
			}
		}
	}
}


/**
 2点間を通る線について、座標からax+by+c = 0 を出すメソッド
 */
float linePrmGetA(float cx, float cy, float px, float py) {
	
	float xlk = px - cx;
	float ylk = py - cy;
	float rsq = pow( xlk, 2 ) + pow( ylk, 2 );
	
	float rinv = 1/sqrt(rsq);
	
	
	float a = -ylk * rinv;
	return a;
}

float linePrmGetB(float cx, float cy, float px, float py) {
	
	float xlk = px - cx;
	float ylk = py - cy;
	float rsq = pow( xlk, 2 ) + pow( ylk, 2 );
	
	float rinv = 1/sqrt(rsq);
	
	
	float b = xlk * rinv;
	return b;
}

float linePrmGetC(float cx, float cy, float px, float py) {
	
	float xlk = px - cx;
	float ylk = py - cy;
	float rsq = pow( xlk, 2 ) + pow( ylk, 2 );
	
	float rinv = 1.0/sqrt(rsq);
	
	
	float c = ((cx * py) - (px * cy)) * rinv;//桁が大きすぎる、、なんだこれ。
	return c;
}

//直線と円の接点座標を返すメソッド
CGPoint lineCrclCrsPt (float circleX, float circleY, float circleR, 
						  float cx, float cy,
						  float px,float py, 
						  float nX,float nY) {
	
	//直線の各係数を求める
	float a = linePrmGetA(cx,cy, px,py);
	float b = linePrmGetB(cx,cy, px,py);
	float c = linePrmGetC(cx,cy, px,py);
	
	
	float rt = 1.0 / (pow(a, 2) + pow(b, 2));
	
	float factor = -c * rt;
	float xo = a * factor;
	float yo = b * factor;
	
	rt = sqrt(rt);//平方根
	
	float f =  b * rt;
	float g = -a * rt;
	
	float fsq = f*f;
	float gsq = g*g;
	float fgsq = fsq+gsq;
	

	
	float xjo = circleX - xo;
	float yjo = circleY - yo;
	float fygx = (f * yjo) - (g * xjo);
	rt = ( circleR * circleR * fgsq ) - ( fygx * fygx );
	
	
	
	//交点なし
	if( rt < 0 ) {
		CGPoint ret = CGPointMake(0, 0);
		return ret;
	}
	
	float fxgy = (f*xjo)+(g*yjo);
	
	
	//直線と円が接している場合
	if( rt == 0 ){//floatなので0は無い。代替の手法が必要。
		float t = fxgy / fgsq;
		CGPoint ret = CGPointMake(xo + (f * t), yo + (g * t));
		return ret;
	}
	
	//交点が二つの場合	
	rt = sqrt(rt);
	
	float fginv = 1.0 / fgsq;
	float t1 = (fxgy - rt)*fginv;
	float t2 = (fxgy + rt)*fginv;
	float x1 = xo + (f * t1);
	float y1 = yo + (g * t1);
	float x2 = xo + (f * t2);
	float y2 = yo + (g * t2);
	
	float sqdst1 = pow((nX - x1), 2) + pow((nY - y1), 2);
	float sqdst2 = pow((nX - x2), 2 ) + pow((nY - y2), 2);
	
	//nearに近い方の交点を返す
	CGPoint ret = CGPointMake(x2, y2);
	
	if (sqdst1 < sqdst2) {
		ret = CGPointMake(x1, y1);
	}
	return ret;
}



/**
 ラインを描画するメソッド
 αは固定。
 */
void lineFromTo(CGContextRef context, CGPoint start, CGPoint end, UIColor * color) {
	CGContextSetLineWidth(context, 3.5);
	
	CGColorRef col  = CGColorCreateCopyWithAlpha([color CGColor], 0.2);
	
	CGContextSetStrokeColorWithColor(context, col);
	
	CGPoint p [2];
	p[0] = start;
	p[1] = end;
	
	CGContextStrokeLineSegments(context, p, 2);
	
	CFRelease(col);
}



/**
 タッチ開始
 */
- (void) touchesBegan:(NSSet * )touches withEvent:(UIEvent * )event {
	
//	NSLog(@"touches_%@",[event allTouches]);//タッチ全体はeventに入っている。 なんでTouchesに入ってないんだろう、、、 setなのに。
//	→スタートだから、ということか。分解能での検出できる２点を見てるわけだ。
	NSLog(@"Touches_count_%d",[touches count]);
	for (UITouch * touch in touches) {
		if (2 <= [touch tapCount]) {
			CGPoint touchPoint = [touch locationInView:self];
			
			[m_controllerId scaleResetX:touchPoint.x withY:touchPoint.y];
			
			return;
		}
	}
	
	
	/**
	 イベントの記録
	 カウントの数確認
	 を行う。
	 */
	if (!m_pinchEvent) {//イベントの種類ごとに振り分ける事で、排他にできる、、という理由。
		NSArray * t = [[event allTouches] allObjects];//配列化する
		
		if ([[event allTouches] count] == 2){
			m_pinchEvent = event;//のちのち識別するためイベントをセットする。この方法は面白い。でも弱点がありそう。
			
			m_lastPinchDist = fabs([[t objectAtIndex:0] locationInView:self].x - [[t objectAtIndex:1] locationInView:self].x);//開始時の2点間の距離を得る(xのみ)
		} else {
			m_lastPoint = CGPointMake([[t objectAtIndex:0] locationInView:self].x, [[t objectAtIndex:0] locationInView:self].y);
		}		
	} 
	
	
}



/**
 タッチの移動
 */
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (event == m_pinchEvent && [[event allTouches] count] == 2) {
		CGFloat thisPinchDist, pinchDiff;//最新の2点間の距離、開始時からの差分
		
		NSArray * t = [[event allTouches] allObjects];//配列化
		thisPinchDist = fabs([[t objectAtIndex:0] locationInView:self].x - [[t objectAtIndex:1] locationInView:self].x);//最新の2点間の距離
		
		pinchDiff = (thisPinchDist - m_lastPinchDist)*0.01f;//差分
		
		[m_controllerId setScale:[m_controllerId getScale]+pinchDiff];
		
		m_lastPinchDist = thisPinchDist;//イベントが発生する度の更新なので、ここで上書き。
	} else {
		
		//前回の位置からの移動分だけ、worldを動かす。
		NSArray * t = [[event allTouches] allObjects];//配列化
		
		[m_controllerId moveWorldX:[[t objectAtIndex:0] locationInView:self].x - m_lastPoint.x withY:[[t objectAtIndex:0] locationInView:self].y - m_lastPoint.y];
		
		m_lastPoint = CGPointMake([[t objectAtIndex:0] locationInView:self].x, [[t objectAtIndex:0] locationInView:self].y);
	
	}
}



/**
 タッチの終了
 */
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (event == m_pinchEvent)
	{
		m_pinchEvent = nil;//イベント削除
		return;
	}
}




- (void)dealloc {
    [super dealloc];
}


@end
