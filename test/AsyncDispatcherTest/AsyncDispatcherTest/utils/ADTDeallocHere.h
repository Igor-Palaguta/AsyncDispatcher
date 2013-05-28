#import <Foundation/Foundation.h>

@class GHAsyncTestCase;

@interface ADTDeallocHere : NSObject

+(id)expectsDeallocOnThread:( NSThread* )thread_
                       test:( GHAsyncTestCase* )test_
                   selector:( SEL )selector_;

-(void)doSomething;

@end
