#import "ADOperationMonitor.h"

#import "ADTimeConversion.h"

@interface ADOperationMonitor ()

@property ( nonatomic, AD_DISPATCH_PROPERTY ) dispatch_group_t group;
@property ( assign ) BOOL isCancelled;

@end

@implementation ADOperationMonitor

@synthesize group = _group;
@synthesize isCancelled;

-(void)dealloc
{
   AD_DISPATCH_RELEASE( _group );
}

-(dispatch_group_t)group
{
   if ( !_group )
   {
      _group = dispatch_group_create();
      AD_DISPATCH_RETAIN( _group );
   }
   return _group;
}

-(void)incrementUsage
{
   dispatch_group_enter( self.group );
}

-(void)decrementUsage
{
   dispatch_group_leave( self.group );
}

-(BOOL)waitForDispatchTime:( dispatch_time_t )dispatch_time_
{
   return dispatch_group_wait( self.group, dispatch_time_ ) == 0;
}

-(BOOL)wait
{
   return [ self waitForDispatchTime: DISPATCH_TIME_FOREVER ];
}

-(BOOL)waitForTimeInterval:( NSTimeInterval )seconds_
{
   return [ self waitForDispatchTime: ADDispatchTimeSinceNow( seconds_ ) ];
}

-(void)cancel
{
   self.isCancelled = YES;
}

@end
