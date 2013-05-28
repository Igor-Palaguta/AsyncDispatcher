#import "ADOperationMonitor.h"

#import "ADTimeConversion.h"

@interface ADOperationMonitor ()
{
   BOOL _isCancelled;
}

@property ( nonatomic, strong ) id< ADRequest > parentRequest;
@property ( nonatomic, AD_DISPATCH_PROPERTY ) dispatch_group_t group;

@end

@implementation ADOperationMonitor

@synthesize parentRequest;
@synthesize group = _group;

-(id)initWithParentRequest:( id< ADRequest > )request_
{
   self = [ super init ];
   if ( self )
   {
      self.parentRequest = request_;
   }
   return self;
}

-(id)init
{
   return [ self initWithParentRequest: nil ];
}

-(void)dealloc
{
   AD_DISPATCH_RELEASE( _group );
}

-(dispatch_group_t)group
{
   if ( !_group )
   {
      _group = dispatch_group_create();
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
   @synchronized (self)
   {
      _isCancelled = YES;
   }
}

-(BOOL)isCancelled
{
   @synchronized (self)
   {
      if ( _isCancelled )
         return YES;

      return self.parentRequest.isCancelled;
   }
}

@end
