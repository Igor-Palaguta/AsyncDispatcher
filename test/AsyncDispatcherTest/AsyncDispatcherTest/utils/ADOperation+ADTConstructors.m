#import "ADOperation+ADTConstructors.h"

ADTDelayFunction ADTNoDelay(void)
{
   return ADTConstDelay( 0.0 );
}

ADTDelayFunction ADTConstDelay( NSTimeInterval delay_ )
{
   return ^NSTimeInterval( NSInteger index_, NSRange range_ )
   {
      return delay_;
   };
}

ADTDelayFunction ADTDirectDelay(void)
{
   return ^NSTimeInterval( NSInteger index_, NSRange range_ )
   {
      return ( index_ - range_.location ) * 0.1;
   };
}

ADTDelayFunction ADTIndexDelay(void)
{
   return ^NSTimeInterval( NSInteger index_, NSRange range_ )
   {
      return index_ * 0.1;
   };
}

ADTDelayFunction ADTReverseDelay(void)
{
   return ^NSTimeInterval( NSInteger index_, NSRange range_ )
   {
      return ( NSMaxRange( range_ ) - index_ ) * 0.1;
   };
}

@implementation ADBlockOperation (ADTConstructors)

+(id)operationWithIndex:( NSInteger )index_
              doneBlock:( ADDoneBlock )done_block_
{
   return [ self operationWithIndex: index_
                          doneBlock: done_block_
                              delay: 0.0 ];
}

+(id)operationWithIndex:( NSInteger )index_
              doneBlock:( ADDoneBlock )done_block_
                  delay:( NSTimeInterval )delay_
{
   NSString* name_ = [ NSString stringWithFormat: @"%d", index_ ];
   if ( delay_ )
   {
      name_ = [ name_ stringByAppendingFormat: @" (%.2f delay)", delay_ ];
   }

   ADWorkerBlock worker_ = ^id( NSError** error_ )
   {
      //NSLog( @"Start operation: %@ time: %@", name_, [ NSDate date ] );

      if ( delay_ != 0.0 )
      {
         [ NSThread sleepForTimeInterval: delay_ ];
      }

      return [ NSNumber numberWithInteger: index_ ];
   };

   ADBlockOperation* operation_ = [ [ self alloc ] initWithName: name_ worker: worker_ ];
   operation_.doneBlock = done_block_;

   return operation_;
}

+(id)operationWithName:( NSString* )name_
      errorDescription:( NSString* )description_
             doneBlock:( ADDoneBlock )done_block_
                 delay:( NSTimeInterval )delay_
{
   ADWorkerBlock worker_ = ^id( NSError** error_ )
   {
      if ( delay_ != 0.0 )
      {
         [ NSThread sleepForTimeInterval: delay_ ];
      }

      *error_ = [ NSError errorWithDomain: @"com.AsyncDispatcherTest"
                                     code: 0
                                 userInfo: [ NSDictionary dictionaryWithObject: description_ forKey: NSLocalizedDescriptionKey ] ];

      return nil;
   };

   ADBlockOperation* operation_ = [ [ self alloc ] initWithName: name_ worker: worker_ ];
   operation_.doneBlock = done_block_;
   return operation_;
}

+(id)operationWithName:( NSString* )name_
      errorDescription:( NSString* )description_
             doneBlock:( ADDoneBlock )done_block_
{
   return [ self operationWithName: name_ errorDescription: description_ doneBlock: done_block_ delay: 0.0 ];
}

@end

@implementation ADCompositeOperation (ADTConstructors)

+(id)compositeWithOperations:( NSArray* )operations_
                        name:( NSString* )name_
                   doneBlock:( ADDoneBlock )done_block_
{
   ADCompositeOperation* operation_ = [ [ self alloc ] initWithName: name_
                                                         operations: operations_ ];

   operation_.doneBlock = done_block_;

   return operation_;
}

@end

@implementation NSArray (ADTConstructors)

+(id)arrayWithOperationsFromRange:( NSRange )range_
                        doneBlock:( ADDoneBlock )done_block_
                    delayFunction:( ADTDelayFunction )delay_function_
                             step:( NSUInteger )step_
{
   NSMutableArray* operations_ = [ NSMutableArray arrayWithCapacity: range_.length ];
   [ operations_ addOperationsFromRange: range_
                              doneBlock: done_block_
                          delayFunction: delay_function_
                                   step: step_ ];
   
   return [ self arrayWithArray: operations_ ];
}

+(id)arrayWithOperationsFromRange:( NSRange )range_
                        doneBlock:( ADDoneBlock )done_block_
                    delayFunction:( ADTDelayFunction )delay_function_
{
   return [ self arrayWithOperationsFromRange: range_
                                    doneBlock: done_block_
                                delayFunction: delay_function_
                                         step: 1 ];
}

+(id)arrayWithOperationsFromRange:( NSRange )range_
                        doneBlock:( ADDoneBlock )done_block_
{
   return [ self arrayWithOperationsFromRange: range_
                                    doneBlock: done_block_
                                delayFunction: ADTNoDelay() ];
}

-(id)reverseOrder
{
   return [ [ self reverseObjectEnumerator ] allObjects ];
}

@end

@implementation NSMutableArray (ADTConstructors)

-(void)addOperationsFromRange:( NSRange )range_
                        doneBlock:( ADDoneBlock )done_block_
                    delayFunction:( ADTDelayFunction )delay_function_
                             step:( NSUInteger )step_
{
   for ( NSInteger i_ = range_.location; i_ < NSMaxRange( range_ ); i_ += step_ )
   {
      NSTimeInterval delay_ = delay_function_( i_, range_ );
      [ self addObject: [ ADBlockOperation operationWithIndex: i_
                                                    doneBlock: done_block_
                                                        delay: delay_ ] ];
   }
}

-(void)addOperationsFromRange:( NSRange )range_
                    doneBlock:( ADDoneBlock )done_block_
                delayFunction:( ADTDelayFunction )delay_function_
{
   [ self addOperationsFromRange: range_
                       doneBlock: done_block_
                   delayFunction: delay_function_
                            step: 1 ];
}

-(void)addOperationsFromRange:( NSRange )range_
                    doneBlock:( ADDoneBlock )done_block_
{
   [ self addOperationsFromRange: range_
                       doneBlock: done_block_
                   delayFunction: ADTNoDelay() ];
}

@end
