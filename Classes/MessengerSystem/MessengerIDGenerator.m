//
//  MessengerIDGenerator.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/09/15.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "MessengerIDGenerator.h"


@implementation MessengerIDGenerator

/**
 MID発行メソッド
 UUIDを作成する 解放は使う側で行う。
 */
+ (NSString * ) getMID {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);
	NSString * uuidString = (NSString * )CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return uuidString;
}

@end
