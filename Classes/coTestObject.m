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
	[messenger inputParent:PARENTNAME];
	return self;
}


- (id) init2 {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_3];
		[messenger inputParent:PARENTNAME];
	}
	return self;
}

- (id) init3 {
	if (self = [super init]) {
		messenger = [[MessengerSystem alloc] initWithBodyID:self withSelector:@selector(test:) withName:CHILD_2];
		[messenger inputParent:CHILD_3];
		//[messenger callMyself:COMMAND_YEAH,
//		 [messenger withDelay:0.4],
//		 nil];
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
		case -1295402496://COMMAND_YEAH
			
			if ([messenger hasParent]) {
				
			} else {
				[messenger inputParent:PARENTNAME];
			}

			
			[messenger callMyself:COMMAND_YEAH,
			 [messenger withDelay:0.4],
			 nil];
			
			break;
		case -1295402495://COMMAND_OOPS
			NSLog(@"子供に到着しました");
			[messenger callParent:COMMAND_YEAH,
			 [messenger withDelay:0.5],
			 nil];
			
			[messenger removeFromParent];
			
			NSLog(@"到着後の処理が完了しました");			
			break;
		case 748839144://COMMAND_CHILDS
			NSLog(@"COMMAND_CHILDS到着_%@",[messenger getMyMID]);
			[messenger callParent:COMMAND_ADD_CHILD,
			 [messenger withRemoteFrom:self withSelector:@selector(forInvocaton:)],
			 [messenger withDelay:0.4],
			 nil];
			
			[messenger callMyself:COMMAND_CHILDS,
			 [messenger withDelay:0.4],
			 nil];
			
			
			break;
			
		case -416910212://COMMAND_DELAYANDREMOTE
			NSLog(@"ディレイで到達_%@",[messenger getMyMID]);
			[messenger remoteInvocation:dict, @"親のメソッドを子供が起動", nil];
			
//			[messenger callParent:COMMAND_DELAYANDREMOTE_RET, 
//			 [messenger withRemoteFrom:self withSelector:@selector(forInvocaton:)],
//			 nil];
//			
//			[messenger callParent:COMMAND_DELAYANDREMOTE_RET_2, 
//			 [messenger withRemoteFrom:self withSelector:@selector(forInvocaton:)],
//			 [messenger withDelay:0.4],
//			 nil];
			
			[messenger callParent:COMMAND_ADD_CHILD,
			 [messenger withRemoteFrom:self withSelector:@selector(forInvocaton:)],
			// [messenger withDelay:0.4],
			 nil];
			break;
			
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
