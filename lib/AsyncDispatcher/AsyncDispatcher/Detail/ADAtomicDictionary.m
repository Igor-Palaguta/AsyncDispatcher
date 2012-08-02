#import "ADAtomicDictionary.h"

@interface ADPair : NSObject

@property ( nonatomic, strong ) id key;
@property ( nonatomic, strong ) id object;

+(id)pairWithObject:( id )object_
             forKey:( id )key_;

@end

@implementation ADPair

@synthesize key;
@synthesize object;

+(id)pairWithObject:( id )object_
             forKey:( id )key_
{
   ADPair* pair_ = [ self new ];
   pair_.object = object_;
   pair_.key = key_;
   return pair_;
}

-(NSString*)description
{
   return [ NSString stringWithFormat: @"%@: %@", self.key, self.object ];
}

@end

@interface ADAtomicDictionary ()

@property ( nonatomic, strong ) NSMutableDictionary* mutableDictionary;
//is usefull for printing in correct order
@property ( nonatomic, strong ) NSMutableArray* mutableArray;

@end

@implementation ADAtomicDictionary

@synthesize mutableDictionary = _dictionary;
@synthesize mutableArray = _array;

-(NSMutableDictionary*)mutableDictionary
{
   if ( !_dictionary )
   {
      _dictionary = [ NSMutableDictionary dictionary ];
   }
   return _dictionary;
}

-(NSMutableArray*)mutableArray
{
   if ( !_array )
   {
      _array = [ NSMutableArray array ];
   }
   return _array;
}

-(void)setObject:( id )object_
          forKey:( id )key_
{
   @synchronized ( self )
   {
      [ self.mutableDictionary setObject: object_ forKey: key_ ];
      [ self.mutableArray addObject: [ ADPair pairWithObject: object_ forKey: key_ ] ];
   }
}

-(id)objectForKey:( id )key_
{
   @synchronized ( self )
   {
      return [ self.mutableDictionary objectForKey: key_ ];
   }
}

-(NSArray*)pairs
{
   @synchronized ( self )
   {
      return [ self.mutableArray copy ];
   }
}

-(NSString*)description
{
   return [ NSString stringWithFormat: @"{\n%@\n}", [ self.pairs componentsJoinedByString: @",\n" ] ];
}

@end
