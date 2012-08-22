#import <AsyncSaxParser/AsyncSaxParser.h>

#include <list>
#include <stack>
#include <numeric>

typedef std::stack< const ADXMLChar* > element_stack_type;
typedef std::list< NSString* > buffer_type;

static NSUInteger buffer_length( NSUInteger previous_length_, NSString* data_ )
{
   return previous_length_ + [ data_ length ];
}

static NSMutableString* concat_buffer( NSMutableString* total_string_, NSString* data_ )
{
   [ total_string_ appendString: data_ ];
   return total_string_;
}

@interface NSString (XmlBuffer)

+(id)stringWithXmlBuffer:( const buffer_type& )buffer_;

@end

@implementation NSString (XmlBuffer)

+(id)stringWithXmlBuffer:( const buffer_type& )buffer_
{
   NSUInteger size_ = std::accumulate( buffer_.begin(), buffer_.end(), 0, buffer_length );
   NSMutableString* result_ = [ NSMutableString stringWithCapacity: size_ ];
   return std::accumulate( buffer_.begin(), buffer_.end(), result_, concat_buffer );
}

@end

@interface ADSaxParserTest : GHAsyncTestCase< ADSaxHandler >
{
@private
   element_stack_type stack;
   buffer_type buffer;
}

@property ( nonatomic, assign ) NSUInteger numberOfArticles;
@property ( nonatomic, strong ) NSString* fullName;
@property ( nonatomic, strong ) NSString* langFrom;
@property ( nonatomic, strong ) NSString* langTo;
@property ( nonatomic, strong ) NSError* currentError;

@property ( nonatomic, assign ) SEL currentTest;

@end

@implementation ADSaxParserTest

@synthesize numberOfArticles;
@synthesize fullName;
@synthesize langFrom;
@synthesize langTo;
@synthesize currentError;
@synthesize currentTest;

-(void)setUp
{
   self.numberOfArticles = 0;
   self.currentError = nil;
   self.currentTest = 0;
   self.fullName = nil;
   self.langFrom = nil;
   self.langTo = nil;
}

-(void)tearDown
{
   self->buffer.clear();
   //self->stack.clear();
}

-(void)prepareTest:( SEL )cmd_
{
   self.currentTest = cmd_;
   [ self prepare ];
}

-(void)testXmlParsing
{
   [ self prepareTest: _cmd ];

   NSString* file_path_ = [ [ NSBundle mainBundle ] pathForResource: @"big"
                                                             ofType: @"xdxf" ];

   ADSaxParser* parser_ = [ [ ADSaxParser alloc ] initWithContentsOfFile: file_path_
                                                                 handler: self ];

   GHAssertTrue( parser_ != nil, nil );

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 10.0 ];
   
   GHAssertTrue( self.numberOfArticles == 46650, @"Number of articles: %d", self.numberOfArticles );
   GHAssertTrue( self.currentError == nil, nil );
   GHAssertTrue( [ self.fullName isEqualToString: @"English-Russian short dictionary" ], @"Full name is: %@", self.fullName );
   GHAssertTrue( [ self.langFrom isEqualToString: @"ENG" ], @"from: %@", self.langFrom );
   GHAssertTrue( [ self.langTo isEqualToString: @"RUS" ], @"to: %@", self.langTo );
}

-(void)testBadXmlParsing
{
   [ self prepareTest: _cmd ];
   
   NSString* file_path_ = [ [ NSBundle mainBundle ] pathForResource: @"bad"
                                                             ofType: @"xdxf" ];
   
   ADSaxParser* parser_ = [ [ ADSaxParser alloc ] initWithContentsOfFile: file_path_
                                                                 handler: self ];
   
   GHAssertTrue( parser_ != nil, nil );
   
   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1.0 ];

   GHAssertTrue( self.currentError != nil, @"Expects error" );
}

-(void)testBadFileParsing
{
   [ self prepareTest: _cmd ];

   ADSaxParser* parser_ = [ [ ADSaxParser alloc ] initWithContentsOfFile: @"/usr/include/test.xml"
                                                                 handler: self ];
   
   GHAssertTrue( parser_ != nil, nil );

   [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1.0 ];

   GHAssertTrue( self.currentError != nil, @"Expects error" );
}

#pragma mark ADSaxHandler

-(void)didFailWithError:( NSError* )error_
{
   self.currentError = error_;
   [ self notify: kGHUnitWaitStatusSuccess forSelector: self.currentTest ];
}

-(void)didComplete
{
   [ self notify: kGHUnitWaitStatusSuccess forSelector: self.currentTest ];
}

-(void)didStartElementWithName:( const ADXMLChar* )name_
                    attributes:( const ADXMLChar** )attributes_
{
   self->stack.push( name_ );

   if ( strcmp( ( const char* )name_, "ar" ) == 0 )
   {
      self.numberOfArticles++;
   }
   else if ( strcmp( ( const char* )name_, "xdxf" ) == 0 )
   {
      NSDictionary* dictionary_ = [ NSDictionary dictionaryWithAttributes: attributes_ ];
      self.langFrom = [ dictionary_ objectForKey: @"lang_from" ];
      self.langTo = [ dictionary_ objectForKey: @"lang_to" ];
   }
}

-(void)didEndElementWithName:( const ADXMLChar* )name_
{
   if ( strcmp( ( const char* )name_, "full_name" ) == 0 )
   {
      self.fullName = [ [ NSString stringWithXmlBuffer: self->buffer ] stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ] ];
   }

   self->buffer.clear();
   self->stack.pop();
}

-(void)didFoundCharacters:( const ADXMLChar* )characters_
               withLength:( int )length_
{
   const char* current_element_ = ( const char* )self->stack.top();

   if ( strcmp( current_element_, "full_name" ) == 0 )
   {
      NSString* data_ = [ [ NSString alloc ] initWithBytesNoCopy: ( void* )characters_
                                                          length: length_
                                                        encoding: NSUTF8StringEncoding
                                                    freeWhenDone: NO ];

      self->buffer.push_back( data_ );
   }
}

-(void)didStartDocument
{
   NSLog( @"didStartDocument" );
}

-(void)didEndDocument
{
   NSLog( @"didEndDocument" );
}

@end
