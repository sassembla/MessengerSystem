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

- (id) init5 {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_5];
		[messenger callMyself:@"遅延実行",
		 [messenger withDelay:0.5],
		 nil];
		
		
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
	NSLog(@"messenger_n_%d",n);
	
	
	
	if ([[messenger getExecAsString:dict] isEqualToString:@"遅延実行"]) {
		[messenger inputParent:CHILD_1];
		
		[messenger callMyself:@"遅延実行2",
		 [messenger withDelay:0.2],
		 nil];
	}
	
	if ([[messenger getExecAsString:dict] isEqualToString:@"遅延実行2"]) {
		[messenger callMyself:@"遅延実行2",
		 [messenger withDelay:0.2],
		 nil];
	}
	
	
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
