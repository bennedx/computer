grammar MachineCodeDefintion

@parser::header 
{
using MachineCode.Parser;
}

@lexer::header
{
using MachineCode.Parser;
}

file        :   lines+=
                (   lines+=lineDefinition
                |   registers+=registerDefinition
                |   flags+=flagDefinition
                |   macros+=macroDefinition
                |   instructions+=instructionDefinition
                |   types+=typeDefinition
                )+
            ;

lineDefinition
            :   THING IS LINE NUMBER NEWLINE+
            ;

registerDefinition
            :   THING IS size=NUMBER BIT INTERNAL? REGISTER NUMBER
                actions+=readOrWriteDefinition+ NEWLINE+
            ;

readOrWriteDefintion
            :   direction=( READ | WRITE | BEFORE ) (WHEN condition)? NEWLINE*
                (   must=MUST CONBINE
                |   cannot=CANNOT COMBINE
                |   oneLine=thingList
                |   LBRACE NEWLINE* lines+=thingList ( NEWLINE+ lines+=thingList )* NEWLINE* RBRACE
                )
            ;

condition   :   THING IN thingList ( FAIL STRING )?
            ;

flagDefinition
            :   THING IS FLAG NUMBER ( BANG THING )? LINE NUMBER
            ;

macroDefinition
            :   THING (LBRACKET param=MACRO RBRACKET)? IS
                (   WRITE ( valueMacro=MACRO | valueThing=THING | valueNumber=NUMBER ) INTO LINE numberList
                |   FLAG NUMBER ( BANG MACRO )? LINE NUMBER
                |   (READ | WRITE) LBRACKET ( targetMacro=MACRO | targetThing=THING | targetNumber=NUMBER) RBRACKET
                |   members=thingList
                )
                IS LINE NUMBER
            ;

macroLine   :   macroCall
            |   WRITE ( MACRO | THING | NUMBER ) INTO LINES numberList
            |   

types       :   MACRO IS mode=(SIGNED | UNSIGNED)? type=( BYTE | WORD )
            ;

numberList  :   NUMBER+
            ;

thingList   :   label=macro COLON )? things+=macroCall ( COMMA? PIPE? things+=macroCall )*
            |   LBRACE things+=macroCall ( COMMA things+=macroCall)* RBRACE
            ;

macroCall   :   (   root=THING
                |   ( READ | WRITE) LBRACKET ( MACRO | THING ) RBRACKET
                |   LPAREN root=THING ( PLUS LBRACKET index=MACRO RBRACKET )? RPAREN
                    // root != index != param
                )   ( LBRACKET param=(MACRO | THING | NUMBER) RBRACKET )?
            ;
            

fragment BINDIGIT
            :   [01] ;

fragment DECDIGIT
            :   [0-9] ;

fragment HEXDIGIT
            :   [0-9a-fA-F] ;

NUMBER      :   '0' BINDIGIT+
            |   HEXDIGIT+ [hH]
            |   DECDIGIT+
            ;

STRING      :   '"' ~('\n'|'\r')*? '"'
            |   '\'' ~('\n'|'\r')*? '\''
            ;

BANG        :   '!' ;
COLON       :   ':' ;
EQ          :   '-' ;
RBRACE      :   '{' ;
LBRACE      :   '}; ;
LBRACKET    :   '[' ;
RBRACKET    :   ']' ;
LPAREN      :   '(' ;
RPAREN      :   ')' ;

BEFORE      :   'before'
BIT         :   'bit' ;
BYTE        :   'byte' ;
FLAG        :   'flag' ;
INST        :   'inst' 'ruction'? ;
INTO        :   'into' ;
IS          :   'is' ;
LINE        :   'line' 's'? ;
MULTI       :   'multi\w*byte' | 'multi-byte';
READ        :   'read' ;
REGISTER    :   'register' ;
SIGNED      :   'signed' ;
TEST        ;   'test' ;
WORD        :   'word' ;
WRITE       :   'write' ;

MACRO       :   [a-z][a-z0-9-]* ;
THING       :   [A-Z][A-Z0-9-]* ;

NEWLINE     :   '\r'? '\n' ; // -> channel(HIDDEN);
LINECOMMENT :   '//' ~('\n'|'\r')* -> channel(HIDDEN);
BLOCKCOMMENT:   '/*' .*? '*/' -> channel(HIDDEN);