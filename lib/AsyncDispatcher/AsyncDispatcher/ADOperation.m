#import "ADOperation.h"

#import "ADSession.h"
#import "ADBlockWrappers.h"

#import "Detail/ADOperation+Private.h"
#import "Detail/ADRequestHolder.h"

@interface ADOperation ()

@property ( nonatomic, strong ) NSString* name;

@end

@implementation ADOperation

@synthesize name;
@synthesize doneBlock;
@synthesize transformBlock;
@synthesize priority;

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
   ADRequestHolder* holder_ = [ ADRequestHolder new ];

   id< ADRequest > request_ =
   [ self asyncWithDoneBlock: ^( id< ADResult > result_ )
    {
       [ session_ removeRequest: holder_ ];
    }];

   holder_.request = request_;
   [ session_ addRequest: holder_ ];

   return request_;
}

-(id< ADRequest >)async
{
   ADSession* session_ = [ ADSession sharedSession ];

   return [ self asyncInSession: session_ ];
}

-(id)copyWithZone:( NSZone* )zone_
{
   ADOperation* copy_ = [ [ [ self class ] allocWithZone: zone_ ] initWithName: self.name ];
   copy_.doneBlock = self.doneBlock;
   copy_.transformBlock = self.transformBlock;
   return copy_;
}

-(void)addFirstDoneBlock:( ADDoneBlock )done_block_
{
   self.doneBlock = ADDoneBlockSum( done_block_, self.doneBlock );
}

@end

