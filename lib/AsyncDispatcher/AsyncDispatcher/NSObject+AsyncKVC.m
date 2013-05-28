#import "NSObject+AsyncKVC.h"

#import "ADMutableResult.h"
#import "ADOperation.h"
#import "ADSession.h"

#import "Detail/ADOperationSubscribers.h"

#import <objc/runtime.h>
#import <objc/message.h>

static char subscribers_association_;

@implementation NSObject (AsyncKVC)

-(NSMutableDictionary*)asyncSubscribersByKey
{
   NSMutableDictionary* subscribers_by_key_ = ( NSMutableDictionary* )objc_getAssociatedObject( self, &subscribers_association_ );
   if ( !subscribers_by_key_ )
   {
      subscribers_by_key_ = [ NSMutableDictionary dictionary ];
      objc_setAssociatedObject( self
                               , &subscribers_association_
                               , subscribers_by_key_
                               , OBJC_ASSOCIATION_RETAIN_NONATOMIC );
   }
   return subscribers_by_key_;
}

-(void)setAsyncSubscribers:( ADOperationSubscribers* )subscribers_
                    forKey:( NSString* )key_
{
   NSMutableDictionary* subscribers_by_key_ = [ self asyncSubscribersByKey ];

   if ( subscribers_ )
   {
      [ subscribers_by_key_ setObject: subscribers_ forKey: key_ ];
   }
   else
   {
      [ subscribers_by_key_ removeObjectForKey: key_ ];
   }
}

-(ADOperationSubscribers*)asyncSubscribersForKey:( NSString* )key_
{
   return [ [ self asyncSubscribersByKey ] objectForKey: key_ ];
}

-(void)processAsyncSubscribersForKey:( NSString* )key_
                          withResult:( id< ADResult > )result_
{
   ADOperationSubscribers* subscribers_ = [ self asyncSubscribersForKey: key_ ];

   [ subscribers_ sendToSubscribersResult: result_ ];

   [ self setAsyncSubscribers: nil forKey: key_ ];
}

-(SEL)asyncOperationSelectorForKey:( NSString* )key_
{
   NSString* capitablized_letter_ = [ [ key_ substringToIndex: 1 ] uppercaseString ];

   NSString* uppercase_name_ = [ key_ stringByReplacingCharactersInRange: NSMakeRange( 0, 1 )
                                                              withString: capitablized_letter_ ];

   NSString* selector_name_ = [ @"asyncOperationFor" stringByAppendingString: uppercase_name_ ];

   return NSSelectorFromString( selector_name_ );
}

-(ADOperation*)asyncOperationForKey:( NSString* )key_
{
   return ( ADOperation* )objc_msgSend( self
                                       , [ self asyncOperationSelectorForKey: key_ ] );
}

-(ADDoneBlock)doneBlockForKey:( NSString* )key_
{
   return ^( id< ADResult > result_ )
   {
      @synchronized ( self )
      {
         if ( !result_.isCancelled && result_.result )
         {
            [ self setValue: result_.result forKey: key_ ];
         }

         [ self processAsyncSubscribersForKey: key_ withResult: result_ ];
      }
   };
}

-(ADOperation*)wrappedAsyncOperationForKey:( NSString* )key_
{
   ADDoneBlock set_value_block_ = [ self doneBlockForKey: key_ ];

   ADOperation* operation_ = [ self asyncOperationForKey: key_ ];
   NSAssert( operation_, @"asyncOperationForKey: %@ must return operation", key_ );

   ADOperation* copy_operation_ = [ operation_ copy ];
   [ copy_operation_ addFirstDoneBlock: set_value_block_ ];

   return copy_operation_;
}

-(ADSession*)sessionForAsyncOperationWithKey:( NSString* )key_
{
   return [ ADSession sharedSession ];
}

-(void)asyncValueForKey:( NSString* )key_
              doneBlock:( ADDoneBlock )done_block_
{
   id value_ = nil;

   @synchronized ( self )
   {
      value_ = [ self valueForKey: key_ ];
      if ( !value_ )
      {
         ADOperationSubscribers* subscribers_ = [ self asyncSubscribersForKey: key_ ];
         if ( !subscribers_ )
         {
            ADOperation* operation_ = [ self wrappedAsyncOperationForKey: key_ ];
            subscribers_ = [ ADOperationSubscribers new ];
            [ subscribers_ addSubscriber: done_block_ ];
            [ self setAsyncSubscribers: subscribers_ forKey: key_ ];
            [ operation_ asyncInSession: [ self sessionForAsyncOperationWithKey: key_ ] ];
         }
         else
         {
            [ subscribers_ addSubscriber: done_block_ ];
         }
      }
   }

   if ( value_ && done_block_ )
   {
      done_block_( [ [ ADMutableResult alloc ] initWithResult: value_ ] );
   }
}

@end
