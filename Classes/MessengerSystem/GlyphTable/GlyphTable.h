//
//  GlyphTable.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/24.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlyphTable : NSObject {

}
+ (void) drawString:(CGContextRef)context string:(NSString * )str 
		   withFont:(NSString * )fontName 
	   withFontSize:(int)size 
		  withColor:(UIColor * )color
				atX:(float)x 
				atY:(float)y;

@end