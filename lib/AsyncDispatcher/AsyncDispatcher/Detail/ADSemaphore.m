#import "ADSemaphore.h"

#import "ADDispatchArcDefs.h"

#import "ADTimeConversion.h"

@interface ADSemaphore ()

@property ( nonatomic, AD_DISPATCH_PROPERTY ) dispatch_semaphore_t semaphore;

@end

@implementation ADSemaphore

@synthesize semaphore;

-(void)dealloc
{
   AD_DISPATCH_RELEASE( self.semaphore );
}

-(id)initWithValue:( NSUInteger )value_
{
   self = [ super init ];
   if ( self )
   {
      self.semaphore = dispatch_semaphore_create( value_ );
      AD_DISPATCH_RETAIN( self.semaphore );
   }
   return self;
}

+(id)semaphoreWithValue:( NSUInteger )value_
{
   return [ [ self alloc ] initWithValue: value_ ];
}

-(BOOL)waitForDispatchTime:( dispatch_time_t )dispatch_time_
{
   return dispatch_semaphore_wait( self.semaphore, dispatch_time_ ) == 0;
}

-(BOOL)wait
{
   return [ self waitForDispatchTime: DISPATCH_TIME_FOREVER ];
}

-(BOOL)waitForTimeInterval:( NSTimeInterval )seconds_
{
   return [ self waitForDispatchTime: ADDispatchTimeSinceNow( seconds_ ) ];
}

-(void)signal
{
   dispatch_semaphore_signal( self.semaphore );
}

@end
