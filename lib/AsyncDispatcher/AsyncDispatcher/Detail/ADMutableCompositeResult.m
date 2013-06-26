#import "ADMutableCompositeResult.h"

#import "ADAtomicDictionary.h"

@interface ADMutableCompositeResult ()

@end

@implementation ADMutableCompositeResult

-(id)init
{
   return [ self initWithResult: [ ADAtomicDictionary new ] ];
}

-(ADAtomicDictionary*)results
{
   return ( ADAtomicDictionary* )[ self result ];
}

-(void)inheritErrorFromResult:( id< ADResult > )result_
{
   if ( result_.error && !self.error )
   {
      @synchronized ( self )
      {
         if ( !self.error )
         {
            self.error = result_.error;
         }
      }
   }
}

-(void)setResult:( id< ADResult > )result_
         forName:( NSString* )name_
{
   [ self inheritErrorFromResult: result_ ];

   if ( name_ )
   {
      [ self.results setObject: result_ forKey: name_ ];
   }
}

-(id< ADResult >)resultForName:( NSString* )name_
{
   return [ self.results objectForKey: name_ ];
}

@end
