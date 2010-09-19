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
		
	}
	messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_1];
	[messenger inputToMyParentWithName:PARENTNAME];
	return self;
}


- (id) init2 {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_1];
		[messenger inputToMyParentWithName:PARENTNAME];
	}
	return self;
}


- (void)test:(NSNotification * )notification {
	
	NSMutableDictionary * dict = (NSMutableDictionary *)[notification userInfo];
	
	NSLog(@"子供に到達_%@", notification);
	
	
	int n = [messenger getExecAsInt:dict];
	NSLog(@"messengern_%d",n);
	
	
	
	
	switch (n) {
		case -1295402496://COMMAND_YEAH
			NSLog(@"帰属部分に到着");
			break;
		case -1295402495://COMMAND_OOPS
			NSLog(@"子供に到着しました");
			[messenger callParent:COMMAND_YEAH,
			 [messenger withDelay:0.5],
			 nil];
			
			NSLog(@"到着後の処理が完了しました");			
			break;
		case 748839144://COMMAND_CHILDS
			NSLog(@"COMMAND_CHILDS到着_%@",[messenger getMyMID]);
			break;
			
	}
	
	
	//あとは好きにして！
}


@end
