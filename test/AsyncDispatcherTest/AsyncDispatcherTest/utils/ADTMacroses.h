#ifndef AsyncDispatcherTest_ADTestMacroses_h
#define AsyncDispatcherTest_ADTestMacroses_h

#define ADT_CHECK_CANCEL_AND_INCREMENT_COUNT( counter_ ) ^( id< ADResult > result_ ) \
{ \
   GHAssertTrue( result_.isCancelled, @"doneBlock should be cancelled" ); \
   ++counter_; \
}

#define ADT_INCREMENT_SUCCESS_CANCELLED( success_counter_, cancelled_counter_ ) ^( id< ADResult > result_ ) \
{ \
   if ( result_.isCancelled ) \
   { \
      ++cancelled_counter_; \
   } \
   else if ( !result_.error ) \
   { \
      ++success_counter_; \
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
   ++counter_; \
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

#endif
