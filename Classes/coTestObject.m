//
//  coTestObject.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "coTestObject.h"
#import "NameList.h"


@implementation coTestObject
- (id) init {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_1];
		[messenger inputToMyParentWithName:PARENTNAME];
	}
	return self;
}


- (id) init2 {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_2];
		[messenger inputToMyParentWithName:PARENTNAME];
	}
	return self;
}


- (void)test:(NSNotification * )notification {
	
	NSLog(@"test_notification_%@",notification);
	
	//あとは好きにして！
}


@end
