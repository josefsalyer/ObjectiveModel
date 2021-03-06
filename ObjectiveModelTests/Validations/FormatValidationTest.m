/*
 * Copyright © 2011-2012 Michael R. Fleet (github.com/f1337)
 *
 * Portions of this software were translated from Ruby on Rails,
 * Copyright © 2004-2012 David Heinemeier Hansson.
 * https://github.com/rails/rails/blob/master/activemodel/test/cases/validations/format_validation_test.rb
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */



#import "FormatValidationTest.h"
#import "Topic.h"
#import <ObjectiveModel/Validations.h>



@implementation FormatValidationTest



#pragma mark - SETUP/TEARDOWN



- (void)tearDown
{
    [Topic removeAllValidations];
    [super tearDown];
}



#pragma mark - TRANSLITERATED RoR TESTS



- (void)testValidatesFormat
{
    // Topic.validates_format_of(:title, :content, :with => /^Validation\smacros \w+!$/, :message => "is bad data")
    [Topic validatesFormatOf:[NSArray arrayWithObjects:@"title", @"content", nil] withInitBlock:^(OMValidator *validator) {
        OMFormatValidator *myValidator = (OMFormatValidator *)validator;
        [myValidator setPattern:@"^Validation\\smacros \\w+!$"];
        [myValidator setMessage:@"is bad data"];
    }];

    // t = Topic.new("title" => "i'm incorrect", "content" => "Validation macros rule!")
    Topic *topic = [[Topic alloc] init];
    [topic setTitle:@"i'm incorrect"];
    [topic setContent:@"Validation macros rule!"];

    // assert t.invalid?, "Shouldn't be valid"
    // assert_equal ["is bad data"], t.errors[:title]
    OMAssertModelIsInvalid(topic, @"is bad data", [NSArray arrayWithObject:@"title"]);
    // assert t.errors[:content].empty?
    OMAssertPropertyIsValid(@"content", topic);

    // t.title = "Validation macros rule!"
    [topic setTitle:@"Validation macros rule!"];

    // assert t.valid?
    OMAssertModelIsValid(topic);
    // assert t.errors[:title].empty?
    OMAssertPropertyIsValid(@"title", topic);
}



- (void)testValidateFormatWithAllowBlank
{
    // Topic.validates_format_of(:title, :with => /^Validation\smacros \w+!$/, :allow_blank => true)
    [Topic validatesFormatOf:@"title" withInitBlock:^(OMValidator *validator) {
        OMFormatValidator *myValidator = (OMFormatValidator *)validator;
        [myValidator setAllowBlank:YES];
        [myValidator setPattern:@"^Validation\\smacros \\w+!$"];
    }];

    // assert Topic.new("title" => "Shouldn't be valid").invalid?
    Topic *topic = [[Topic alloc] init];
    [topic setTitle:@"i'm incorrect"];
    OMAssertModelIsInvalid(topic, @"is invalid", [NSArray arrayWithObject:@"title"]);
    [topic release];

    // assert Topic.new("title" => "").valid?
    topic = [[Topic alloc] init];
    [topic setTitle:@""];
    OMAssertModelIsValid(topic);
    [topic release];

    // assert Topic.new("title" => nil).valid?
    topic = [[Topic alloc] init];
    [topic setTitle:nil];
    OMAssertModelIsValid(topic);
    [topic release];

    // assert Topic.new("title" => "Validation macros rule!").valid?    
    topic = [[Topic alloc] init];
    [topic setTitle:@"Validation macros rule!"];
    OMAssertModelIsValid(topic);
    [topic release];
}



- (void)testValidateFormatNumeric
{
    // Topic.validates_format_of(:title, :content, :with => /^[1-9][0-9]*$/, :message => "is bad data")
    [Topic validatesFormatOf:@"title" withInitBlock:^(OMValidator *validator) {
        OMFormatValidator *myValidator = (OMFormatValidator *)validator;
        [myValidator setPattern:@"^[1-9][0-9]*$"];
        [myValidator setMessage:@"is bad data"];
    }];

    // t = Topic.new("title" => "72x", "content" => "6789")
    Topic *topic = [[Topic alloc] init];
    [topic setTitle:@"72x"];
    [topic setContent:@"6789"];

    // assert t.invalid?, "Shouldn't be valid"
    // assert_equal ["is bad data"], t.errors[:title]
    OMAssertModelIsInvalid(topic, @"is bad data", [NSArray arrayWithObject:@"title"]);
    // assert t.errors[:content].empty?
    OMAssertPropertyIsValid(@"content", topic);

    // t.title = "-11"
    [topic setTitle:@"-11"];
    // assert t.invalid?, "Shouldn't be valid"
    OMAssertModelIsInvalid(topic, @"is bad data", [NSArray arrayWithObject:@"title"]);

    // t.title = "03"
    [topic setTitle:@"03"];
    // assert t.invalid?, "Shouldn't be valid"
    OMAssertModelIsInvalid(topic, @"is bad data", [NSArray arrayWithObject:@"title"]);

    //t.title = "z44"
    [topic setTitle:@"z44"];
    // assert t.invalid?, "Shouldn't be valid"
    OMAssertModelIsInvalid(topic, @"is bad data", [NSArray arrayWithObject:@"title"]);

    // t.title = "5v7"
    [topic setTitle:@"5v7"];
    // assert t.invalid?, "Shouldn't be valid"
    OMAssertModelIsInvalid(topic, @"is bad data", [NSArray arrayWithObject:@"title"]);

    // t.title = "1"
    [topic setTitle:@"1"];
    // assert t.valid?
    OMAssertModelIsValid(topic);
    // assert t.errors[:title].empty?
    OMAssertPropertyIsValid(@"title", topic);
}



- (void)testValidateFormatWithNilValue
{
    [Topic validatesFormatOf:@"title" withInitBlock:^(OMValidator *validator) {
        OMFormatValidator *myValidator = (OMFormatValidator *)validator;
        [myValidator setPattern:@"^Valid Title$"];
    }];
    
    Topic *topic = [[Topic alloc] init];
    OMAssertModelIsInvalid(topic, @"is invalid", [NSArray arrayWithObject:@"title"]);
}



- (void)testValidateFormatWithFormattedMessage
{
    // Topic.validates_format_of(:title, :with => /^Valid Title$/, :message => "can't be %{value}")
    [Topic validatesFormatOf:@"title" withInitBlock:^(OMValidator *validator) {
        OMFormatValidator *myValidator = (OMFormatValidator *)validator;
        [myValidator setPattern:@"^Valid Title$"];
        [myValidator setMessage:@"can't be %{value}"];
    }];

    // t = Topic.new(:title => 'Invalid title')
    Topic *topic = [[Topic alloc] init];
    [topic setTitle:@"Invalid title"];
    // assert t.invalid?
    // assert_equal ["can't be Invalid title"], t.errors[:title]
    OMAssertModelIsInvalid(topic, @"can't be Invalid title", [NSArray arrayWithObject:@"title"]);
}



- (void)testValidateFormatWithShouldMatchPatternNO
{
    // Topic.validates_format_of(:title, :without => /foo/, :message => "should not contain foo")
    [Topic validatesFormatOf:@"title" withInitBlock:^(OMValidator *validator) {
        OMFormatValidator *myValidator = (OMFormatValidator *)validator;
        [myValidator setShouldMatchPattern:NO];
        [myValidator setPattern:@"foo"];
        [myValidator setMessage:@"should not contain foo"];
    }];

    // t = Topic.new
    Topic *topic = [[Topic alloc] init];

    // t.title = "foobar"
    [topic setTitle:@"foobar"];
    // t.valid?
    // assert_equal ["should not contain foo"], t.errors[:title]
    OMAssertModelIsInvalid(topic, @"should not contain foo", [NSArray arrayWithObject:@"title"]);
    
    // t.title = "something else"
    [topic setTitle:@"something else"];
    // t.valid?
    OMAssertModelIsValid(topic);
    // assert_equal [], t.errors[:title]
    OMAssertPropertyIsValid(@"title", topic);
}



- (void)testValidatesFormatWithBlock
{
    // Topic.validates_format_of :content, :with => lambda{ |topic| topic.title == "digit" ? /\A\d+\Z/ : /\A\S+\Z/ }
    [Topic validatesFormatOf:@"content" withInitBlock:^(OMValidator *validator)
     {
         OMFormatValidator *myValidator = (OMFormatValidator *)validator;
         [myValidator setRegularExpressionBlock:^NSRegularExpression *(id topic)
          {
              NSString *pattern = ( [[topic title] isEqualToString:@"digit"] ? @"\\A\\d+\\Z" : @"\\A\\S+\\Z" );
              return [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
          }];
     }];

    // t = Topic.new
    Topic *topic = [[Topic alloc] init];

    // t.title = "digit"
    [topic setTitle:@"digit"];
    // t.content = "Pixies"
    [topic setContent:@"Pixies"];
    // assert t.invalid?
    OMAssertModelIsInvalid(topic, @"is invalid", [NSArray arrayWithObject:@"content"]);

    // t.content = "1234"
    [topic setContent:@"1234"];
    // assert t.valid?
    OMAssertModelIsValid(topic);
}



- (void)testValidatesFormatWithBlockAndPatternMatchesNO
{
    // Topic.validates_format_of :content, :without => lambda{ |topic| topic.title == "characters" ? /\A\d+\Z/ : /\A\S+\Z/ }
    [Topic validatesFormatOf:@"content" withInitBlock:^(OMValidator *validator)
     {
         OMFormatValidator *myValidator = (OMFormatValidator *)validator;
         [myValidator setShouldMatchPattern:NO];
         [myValidator setRegularExpressionBlock:^NSRegularExpression *(id topic)
          {
              NSString *pattern = ( [[topic title] isEqualToString:@"characters"] ? @"\\A\\d+\\Z" : @"\\A\\S+\\Z" );
              return [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
          }];
     }];
    
    // t = Topic.new
    Topic *topic = [[Topic alloc] init];
    
    // t.title = "characters"
    [topic setTitle:@"characters"];
    // t.content = "1234"
    [topic setContent:@"1234"];
    // assert t.invalid?
    OMAssertModelIsInvalid(topic, @"is invalid", [NSArray arrayWithObject:@"content"]);
    
    // t.content = "Pixies"
    [topic setContent:@"Pixies"];
    // assert t.valid?
    OMAssertModelIsValid(topic);
}



- (void)testValidatesFormatWithRegularExpression
{
    [Topic validatesFormatOf:@"content" withInitBlock:^(OMValidator *validator)
     {
         OMFormatValidator *myValidator = (OMFormatValidator *)validator;
         [myValidator setRegularExpression:[NSRegularExpression regularExpressionWithPattern:@"\\A\\d+\\Z" options:0 error:nil]];
     }];
    
    // t = Topic.new
    Topic *topic = [[Topic alloc] init];
    
    // t.content = "Pixies"
    [topic setContent:@"Pixies"];
    // assert t.invalid?
    OMAssertModelIsInvalid(topic, @"is invalid", [NSArray arrayWithObject:@"content"]);
    
    // t.content = "1234"
    [topic setContent:@"1234"];
    // assert t.valid?
    OMAssertModelIsValid(topic);
}



- (void)testValidatesFormatWithRegularExpressionAndPatternMatchesNO
{
    [Topic validatesFormatOf:@"content" withInitBlock:^(OMValidator *validator)
     {
         OMFormatValidator *myValidator = (OMFormatValidator *)validator;
         [myValidator setShouldMatchPattern:NO];
         [myValidator setRegularExpression:[NSRegularExpression regularExpressionWithPattern:@"\\A\\d+\\Z" options:0 error:nil]];
     }];

    // t = Topic.new
    Topic *topic = [[Topic alloc] init];

    // t.content = "1234"
    [topic setContent:@"1234"];
    // assert t.invalid?
    OMAssertModelIsInvalid(topic, @"is invalid", [NSArray arrayWithObject:@"content"]);
    
    // t.content = "Pixies"
    [topic setContent:@"Pixies"];
    // assert t.valid?
    OMAssertModelIsValid(topic);
}



@end
