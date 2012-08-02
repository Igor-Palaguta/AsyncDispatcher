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

-(void)setResult:( id< ADResult > )result_
         forName:( NSString* )name_
{
   if ( !self.error && !result_.isCancelled )
   {
      self.error = result_.error;
   }

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
