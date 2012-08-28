#import <AsyncDispatcher/AsyncDispatcher.h>

#import <Foundation/Foundation.h>

@class GHAsyncTestCase;

extern ADDoneBlock ADNotifySuccess( ADDoneBlock done_block_, GHAsyncTestCase* test_case_, SEL selector_ );

extern ADDoneBlock ADCheckResultOnMainThread( ADDoneBlock done_block_, id expected_result_ );
extern ADDoneBlock ADCheckResultOnBackgroundThread( ADDoneBlock done_block_, id expected_result_ );
extern ADDoneBlock ADCheckResultOnNotMainThread( ADDoneBlock done_block_, id expected_result_ );
extern ADDoneBlock ADCheckResultOnThisThread( ADDoneBlock done_block_, id expected_result_ );