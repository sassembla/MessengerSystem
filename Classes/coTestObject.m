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
		[messenger inputParent:PARENTNAME];
	}
	
	return self;
}


- (id) init2 {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_2];
		[messenger inputParent:CHILD_1];
	}
	return self;
}

- (id) init3 {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_3];
		[messenger inputParent:CHILD_2];
	}
	return self;
}

- (id) init4 {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_4];
		[messenger inputParent:CHILD_3];
	}
	return self;
}

- (void) setParent {
	[messenger inputParent:PARENTNAME];
}

- (void)test:(NSNotification * )notification {
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSLog(@"子供に到達_%@", notification);
	
	
	int n = [messenger getExecAsIntFromDict:dict];
	NSLog(@"messengern_%d",n);
	
	
	
	
	switch (n) {
		default:
		{
			int m = [messenger getExecAsIntFromDict:dict];
			NSLog(@"messenger m_%d",m);
		}
			
			break;
	}
}


/**
 遠隔実行で渡してみる
 */
- (void) forInvocaton:(NSString * )str {
	NSLog(@"forInvocaton_%@",str);
}

- (void) dealloc {
	
	[messenger release];
	
	[super dealloc];
}


@end
