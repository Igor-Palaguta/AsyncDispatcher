#import <AsyncSaxParser/AsyncSaxParser.h>
#import <AsyncDispatcher/AsyncDispatcher.h>

#include <stack>

typedef std::stack< const ADXMLChar* > element_stack_type;

@interface ADSaxParserTest : GHAsyncTestCase< ADSaxHandler >
{
@private
   element_stack_type stack;
}

@property ( nonatomic, strong ) id< ADMutableBuffer > buffer;
@property ( nonatomic, assign ) NSUInteger numberOfArticles;
@property ( nonatomic, strong ) NSString* fullName;
@property ( nonatomic, strong ) NSString* langFrom;
@property ( nonatomic, strong ) NSString* langTo;
@property ( nonatomic, strong ) NSError* currentError;

@property ( nonatomic, assign ) SEL currentTest;

@end

@implementation ADSaxParserTest

@synthesize buffer;
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
   self.buffer = nil;
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
      self.fullName = [ [ self.buffer string ] stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ] ];
   }

   self->stack.pop();
}

-(void)didFoundCharacters:( const ADXMLChar* )characters_
               withLength:( int )length_
{
   const char* current_element_ = ( const char* )self->stack.top();

   if ( strcmp( current_element_, "full_name" ) == 0 )
   {
      if ( self.buffer )
      {
         [ self.buffer addBuffer: characters_
                          length: length_ ];
      }
      else
      {
         self.buffer = [ [ ADMutableBuffer alloc ] initWithBuffer: characters_
                                                           length: length_ ];
      }
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
