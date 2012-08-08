#import "ADSession.h"

#import "ADRequest.h"

#import "Detail/ADAtomicSet.h"

@interface ADSession ()

@property ( nonatomic, strong ) ADAtomicSet* mutableRequests;

@end

@implementation ADSession

@synthesize mutableRequests;

-(id)init
{
   self = [ super init ];
   if ( self )
   {
      self.mutableRequests = [ ADAtomicSet new ];
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
   return [ self.mutableRequests set ];
}

-(void)addRequest:( id< ADRequest > )request_
{
   [ self.mutableRequests addObject: request_ ];
}

-(void)removeRequest:( id< ADRequest > )request_
{
   [ self.mutableRequests removeObject: request_ ];
}

-(NSUInteger)count
{
   return [ self.mutableRequests count ];
}

-(void)cancelAll
{
   NSSet* requests_ = self.requests;
   
   for ( id< ADRequest > request_ in requests_ )
   {
      [ request_ cancel ];
   }
}

@end
