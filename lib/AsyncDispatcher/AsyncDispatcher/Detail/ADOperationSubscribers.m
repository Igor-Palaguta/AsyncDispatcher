#import "ADOperationSubscribers.h"

#import "ADBlockWrappers.h"

@interface ADOperationSubscribers ()

@property ( nonatomic, strong ) NSMutableArray* subscribers;

@end


@implementation ADOperationSubscribers

@synthesize subscribers = _subscribers;

-(NSMutableArray*)subscribers
{
   if ( !_subscribers )
   {
      _subscribers = [ NSMutableArray array ];
   }
   return _subscribers;
}

-(void)addSubscriber:( ADDoneBlock )done_block_
{
   [ self.subscribers addObject: done_block_ ];
}

-(void)sendToSubscribersResult:( id< ADResult > )result_
{
   return ADDoneBlockSumArray( self.subscribers )( result_ );
}

@end
