#import "ADOperation.h"

#import "ADSession.h"

#import "Detail/ADOperation+Private.h"

@interface ADOperation ()

@property ( nonatomic, strong ) NSString* name;

@end

@implementation ADOperation

@synthesize name;
@synthesize doneBlock;
@synthesize transformBlock;

-(id)initWithName:( NSString* )name_
{
   self = [ super init ];
   if ( self )
   {
      self.name = name_;
   }
   return self;
}

-(id< ADRequest >)asyncInSession:( ADSession* )session_
{
   __block id< ADRequest > request_ =
   [ self asyncWithDoneBlock: ^( id< ADResult > result_ )
    {
       [ session_ removeRequest: request_ ];
    }];

   [ session_ addRequest: request_ ];

   return request_;
}

-(id< ADRequest >)async
{
   ADSession* session_ = [ ADSession sharedSession ];

   return [ self asyncInSession: session_ ];
}

@end

