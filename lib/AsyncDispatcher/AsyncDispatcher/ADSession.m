#import "ADSession.h"

#import "ADRequest.h"

@interface ADSession ()

@property ( nonatomic, strong ) NSMutableSet* mutableRequests;

@end

@implementation ADSession

@synthesize mutableRequests;

-(id)init
{
   self = [ super init ];
   if ( self )
   {
      self.mutableRequests = [ NSMutableSet new ];
   }
   return self;
}

+(ADSession*)sharedSession
{
   static ADSession* shared_session_ = nil;
   if ( !shared_session_ )
   {
      shared_session_ = [ self new ];
   }
   return shared_session_;
}

-(NSSet*)requests
{
   @synchronized ( self )
   {
      return [ self.mutableRequests copy ];
   }
}

-(void)addRequest:( id< ADRequest > )request_
{
   @synchronized ( self )
   {
      [ self.mutableRequests addObject: request_ ];
   }
}

-(void)removeRequest:( id< ADRequest > )request_
{
   @synchronized ( self )
   {
      [ self.mutableRequests removeObject: request_ ];
   }
}

-(void)cancelAll
{
   NSSet* requests_ = self.requests;
   
   for ( id< ADRequest > request_ in requests_ )
   {
      [ request_ cancel ];
   }
}

-(NSUInteger)count
{
   @synchronized ( self )
   {
      return [ self.mutableRequests count ];
   }
}

@end
