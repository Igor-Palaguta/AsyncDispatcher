#ifndef AsyncDispatcherTest_ADTestMacroses_h
#define AsyncDispatcherTest_ADTestMacroses_h

#include <libkern/OSAtomic.h>

#define ADT_CHECK_CANCEL_AND_INCREMENT_COUNT( counter_ ) ^( id< ADResult > result_ ) \
{ \
   GHAssertTrue( result_.isCancelled, @"doneBlock should be cancelled" ); \
   OSAtomicIncrement32( &counter_ ); \
}

#define ADT_INCREMENT_SUCCESS_CANCELLED( success_counter_, cancelled_counter_ ) ^( id< ADResult > result_ ) \
{ \
   if ( result_.isCancelled ) \
   { \
      OSAtomicIncrement32( &cancelled_counter_ ); \
   } \
   else if ( !result_.error ) \
   { \
      OSAtomicIncrement32( &success_counter_ ); \
   } \
}

#define ADT_CHECK_TOTAL_COUNT( counter_, expected_count_ ) ^( id< ADResult > result_ ) \
{ \
   NSLog( @"Result:\n%@", result_ ); \
   GHAssertTrue( counter_ == expected_count_, @"Check counter (%d) with total count (%d)", counter_, expected_count_ ); \
   [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ]; \
}

#define ADT_CHECK_AND_INCREMENT_COUNT( counter_ ) ^( id< ADResult > result_ ) \
{ \
   GHAssertTrue( counter_ == [ result_.result integerValue ], @"Check counter (%d) with result (%d)", counter_, [ result_.result integerValue ] ); \
   OSAtomicIncrement32( &counter_ ); \
}

#define ADT_CHECK_RESULT( expected_result_ ) ^( id< ADResult > result_ ) \
{ \
   GHAssertTrue( [ expected_result_ isEqual: result_.result ], @"Check result (%@) with expected result (%@)", result_.result, expected_result_ ); \
   [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ]; \
}

#define ADT_CHECK_TOTAL_COUNT( counter_, expected_count_ ) ^( id< ADResult > result_ ) \
{ \
   NSLog( @"Result:\n%@", result_ ); \
   GHAssertTrue( counter_ == expected_count_, @"Check counter (%d) with total count (%d)", counter_, expected_count_ ); \
   [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ]; \
}

#define ADT_INCREMENT_COUNT( counter_ ) ^( id< ADResult > result_ ) \
{ \
   OSAtomicIncrement32( &counter_ ); \
   NSLog( @"Counter: %d", counter_ ); \
}

#endif
