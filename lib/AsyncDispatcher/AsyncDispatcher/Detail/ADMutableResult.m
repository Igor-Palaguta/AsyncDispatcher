#import "ADMutableResult.h"

@implementation ADMutableResult

@synthesize result;
@synthesize error;
@synthesize cancelled;

-(id)initWithResult:( id )result_
              error:( NSError* )error_
{
   self = [ super init ];
   if ( self )
   {
      self.result = result_;
      self.error = error_;
   }

   return self;
}

-(id)initWithResult:( id )result_
{
   return [ self initWithResult: result_
                          error: nil ];
}

-(id)initWithError:( NSError* )error_
{
   return [ self initWithResult: nil
                          error: error_ ];
}

+(id)cancelledResult
{
   ADMutableResult* result_ = [ self new ];
   result_.cancelled = YES;
   return result_;
}

-(NSString*)description
{
   return [ NSString stringWithFormat: @"{ result: %@, error: %@, cancelled: %d }"
           , self.result
           , [ self.error localizedDescription ]
           , self.isCancelled ];
}

@end
