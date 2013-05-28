#import "ADRequestHolder.h"

@implementation ADRequestHolder

@synthesize request;

-(void)cancel
{
   [ self.request cancel ];
}

-(BOOL)isCancelled
{
   return self.request.isCancelled;
}

-(BOOL)wait
{
   return [ self.request wait ];
}

-(BOOL)waitForTimeInterval:( NSTimeInterval )seconds_
{
   return [ self.request waitForTimeInterval: seconds_ ];
}

-(void)setParentRequest:( id< ADRequest > )request_
{
   [ self.request setParentRequest: request_ ];
}

@end
