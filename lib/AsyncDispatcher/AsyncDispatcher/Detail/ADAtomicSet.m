#import "ADAtomicSet.h"

@interface ADAtomicSet ()

@property ( nonatomic, strong ) NSMutableSet* mutableSet;

@end

@implementation ADAtomicSet

@synthesize mutableSet = _mutableSet;

-(NSMutableSet*)mutableSet
{
   if ( !_mutableSet )
   {
      _mutableSet = [ NSMutableSet new ];
   }
   return _mutableSet;
}

-(NSSet*)set
{
   @synchronized ( self )
   {
      return [ self.mutableSet copy ];
   }
}

-(void)addObject:( id )object_
{
   @synchronized ( self )
   {
      [ self.mutableSet addObject: object_ ];
   }
}

-(void)removeObject:( id )object_
{
   @synchronized ( self )
   {
      [ self.mutableSet removeObject: object_ ];
   }
}

-(NSUInteger)count
{
   @synchronized ( self )
   {
      return [ self.mutableSet count ];
   }
}

@end
