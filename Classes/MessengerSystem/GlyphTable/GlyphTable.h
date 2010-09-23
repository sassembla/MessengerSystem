//
//  GlyphTable.h
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/24.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GlyphTable : NSObject {

}
+ (void) drawString:(CGContextRef)ref string:(NSString * )str withFont:(NSString * )fontName fontSize:(int)size atX:(float)x atY:(float)y;

@end