#import <AsyncDispatcher/AsyncDispatcher.h>

@interface ADAsyncFileReaderTest : GHAsyncTestCase

@end

@implementation ADAsyncFileReaderTest

-(void)testRead
{
   [ self prepare ];

   NSString* file_path_ = [ [ NSBundle mainBundle ] pathForResource: @"big"
                                                             ofType: @"xdxf" ];

   NSData* expected_data_ = [ NSData dataWithContentsOfFile: file_path_ ];

   ADFileStream* file_reader_ = [ [ ADFileStream alloc ] initWithPath: file_path_ ];

   NSUInteger chunk_size_ = 10000;
   __block NSUInteger total_size_ = 0;
   __block NSUInteger reads_count_ = 0;

   [ file_reader_ cyclicRead: chunk_size_ handler: ^BOOL( BOOL eof_, id< ADBuffer > buffer_, NSError* error_ )
    {
       total_size_ += [ buffer_ size ];

       if ( [ buffer_ size ] > 0 )
       {
          reads_count_++;
       }

       if ( eof_ || error_ )
       {
          [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
       }
       return YES;
    }];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1.0 ];

   NSUInteger expected_size_ = [ expected_data_ length ];

   GHAssertTrue( total_size_ == expected_size_, @"Check total size" );

   NSUInteger expected_reads_count_ = expected_size_ / chunk_size_ + 1;
   GHAssertTrue( reads_count_ == expected_reads_count_, @"Compare reads_count_ (%d) and expected_reads_count_(%d)"
                , reads_count_
                , expected_reads_count_ );
}

-(void)testUnexistentFile
{
   [ self prepare ];

   GHAssertThrows( [ [ ADFileStream alloc ] initWithPath: nil ], @"Check file for nil path" );

   ADFileStream* unexistent_file_reader_ = [ [ ADFileStream alloc ] initWithPath: @"/usr/include/unreal.txt" ];
   [ unexistent_file_reader_ read: 1 handler: ^BOOL( BOOL eof_, id< ADBuffer > buffer_, NSError* error_ )
    {
       NSLog( @"Error: %@", error_ );
       if ( error_ )
       {
          [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
       }
       return YES;
    }];

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1.0 ];
}

@end
