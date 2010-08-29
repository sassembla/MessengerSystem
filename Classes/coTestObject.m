//
//  coTestObject.m
//  TestKitTesting
//
//  Created by Inoue 徹 on 10/08/29.
//  Copyright 2010 KISSAKI. All rights reserved.
//

#import "coTestObject.h"


@implementation coTestObject
- (id) init {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:@"child_0" withParent:@"paren"];

	}
	return self;
}

- (void)test:(NSNotification * )notification {
	
	
}


@end
