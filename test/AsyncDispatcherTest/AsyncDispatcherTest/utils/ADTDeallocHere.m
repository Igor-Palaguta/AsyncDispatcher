#import "ADTDeallocHere.h"

@interface ADTDeallocHere ()

@property ( nonatomic, strong ) NSThread* thread;
@property ( nonatomic, strong ) GHAsyncTestCase* test;
@property ( nonatomic, assign ) SEL selector;

@end

@implementation ADTDeallocHere

@synthesize thread;
@synthesize test;
@synthesize selector;

+(id)expectsDeallocOnThread:( NSThread* )thread_
                       test:( GHAsyncTestCase* )test_
                   selector:( SEL )selector_
{
   ADTDeallocHere* instance_ = [ self new ];
   instance_.thread = thread_;
   instance_.test = test_;
   instance_.selector = selector_;
   return instance_;
}

-(void)dealloc
{
   NSAssert( [ NSThread currentThread ] == self.thread, @"Can't be dealloc here" );
   [ self.test notify: kGHUnitWaitStatusSuccess forSelector: self.selector ];
}

-(void)doSomething
{
}

@end
