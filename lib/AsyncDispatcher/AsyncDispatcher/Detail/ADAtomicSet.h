#import <Foundation/Foundation.h>

@interface ADAtomicSet : NSObject

-(NSSet*)set;

-(void)addObject:( id )object_;
-(void)removeObject:( id )object_;

-(NSUInteger)count;

@end
