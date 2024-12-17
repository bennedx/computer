grammar MachineCodeDefinition;

@parser::header 
{
using MachineCode.Parser;
}

@lexer::header
{
using MachineCode.Parser;
}

file        :   definitions+=definition
            ;

definition  :   lines+=lineDefinition
            |   registers+=registerDefinition
            |   flags+=flagDefinition
            |   macros+=macroDefinition
            |   instructions+=instructionDefinition
            |   types+=typeDefinition
            |   sets+=setDefinition
            ;

lineDefinition
            :   THING IS LINE numberList SEMI
            ;

registerDefinition
            :   THING IS size=NUMBER BIT INTERNAL? REGISTER NUMBER
                SEMI
            ;

readOrWriteDefintion
            :   direction=( READ | WRITE | BEFORE ) (WHEN condition)? outputDefinition?
                (   LBRACE lines+=thingList+ RBRACE
                |   lines+=thingList
                )
            ;

condition   :   THING not=NOT? IN thingList
            ;

outputDefinition
            :   OUTPUT ( BY thingList ) LBRACE OPCODE? thingList RBRACE
            ;

flagDefinition
            :   THING ( BANG THING )? IS FLAG NUMBER LINE NUMBER SEMI
            ;

macroDefinition
            :   THING (LBRACKET param=MACRO RBRACKET)? IS outputDefinition?
                (   CANNOT COMBINE
                |   MUST COMBINE
                )?

                lines+=macroLine+
                SEMI
            ;

instructionDefinition
            :   INST opcode=THING thingList outputDefinition?
                MICROCODE? LBRACE lines+=macroLine+ RBRACE
            ;

macroLine   :   macroCall
            |   WRITE ( MACRO | THING | NUMBER ) INTO LINE numberList
            |   readOrWriteDefintion
            ;  

typeDefinition
            :   MACRO IS sign=(SIGNED | UNSIGNED)? type=( BYTE | WORD )
            ;

setDefinition
            :   MACRO IS theSet SEMI
            ;

theSet      :   LBRACE
                (   MACRO       // sb
                |   THING       // A F H L BC DE (FP+[ri])
                |   PIPE        // |
                )*
                RBRACE
            ;

numberList  :   NUMBER+
            |   NUMBER MINUS NUMBER
            ;

thingList   :   ( PIPE? things+=macroCall )+
            |   LBRACE ( PIPE? things+=macroCall )+ RBRACE
            ;

macroCall   :   (   root=THING
                |   ( READ | WRITE) LBRACKET ( MACRO | THING ) RBRACKET
                // how are we going to handle (FP+[ri])?
                //|   LPAREN root=THING ( PLUS LBRACKET index=MACRO RBRACKET )? RPAREN
                    // root != index != param
                )   ( LBRACKET param=(MACRO | THING | NUMBER) RBRACKET )?
            ;



fragment BINDIGIT
            :   [01];

fragment DECDIGIT
            :   [0-9];

fragment HEXDIGIT
            :   [0-9a-fA-F];

NUMBER      :   '0' BINDIGIT+
            |   HEXDIGIT+ [hH]
            |   DECDIGIT+
            ;

STRING      :   '"' ~('\n'|'\r')*? '"'
            |   '\'' ~('\n'|'\r')*? '\''
            ;

BANG        :   '!';
COLON       :   ':';
EQ          :   '=';
MINUS       :   '-';
PIPE        :   '|';
SEMI        :   ';';

RBRACE      :   '{';
LBRACE      :   '}';
LBRACKET    :   '[';
RBRACKET    :   ']';
LPAREN      :   '(';
RPAREN      :   ')';

BEFORE      :   'before';
BIT         :   'bit';
BY          :   'by';
BYTE        :   'byte';
CANNOT      :   'cannot';
COMBINE     :   'combine';
FLAG        :   'flag';
INST        :   'inst' 'ruction'?;
INTERNAL    :   'internal';
IN          :   'in';
INTO        :   'into';
IS          :   'is';
LINE        :   'line' 's'?;
MICROCODE   :   'microcode';
MULTI       :   'multi' WHITESPACE 'byte' | 'multi-byte' | 'multibyte';
MUST        :   'must';
NOT         :   'not';
OPCODE      :   'opcode';
OUTPUT      :   'output';
READ        :   'read';
REGISTER    :   'register';
SIGNED      :   'signed';
TEST        :   'test';
UNSIGNED    :   'unsigned';
WHEN        :   'when';
WORD        :   'word';
WRITE       :   'write';



MACRO       :   [(a-z][a-z0-9-]* ;

// the :L/:R is only used with 16-bit registers
THING       :   [A-Z][A-Z0-9-]* ( ':' ( 'L' | 'R' ) )? 
            //|   \( (?<register>[A-Z0-9]]+) ( \+ \[ (?<index>[A-Z0-9]+) ] )? \) ( \( (?<argument>[A-Z0-9]+) \) )?
            ;

NEWLINE     :   '\r'? '\n' ; // -> channel(HIDDEN);
LINECOMMENT :   '//' ~('\n'|'\r')* -> channel(HIDDEN);
BLOCKCOMMENT:   '/*' .*? '*/' -> channel(HIDDEN);

// a comma(,) is whitespace in this langugage
WHITESPACE  :   [ \t,] -> channel(HIDDEN);

/*
\( (?<register>:\w+) ( + \[ (?<index>:\w+)? ] )?

(HL)
(FP+[ri])
(FP+[ri])(8) 

( [+] \[ (?<index>:\w+)? ] )? ([(] (?<argument>:\w+) [)])?
*/