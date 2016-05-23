
signature PARSE = sig

    (* The position in a text being parsed. *)
    datatype pos = POS of {column : int, row : int}
                 | EOF

    (* A specific parse error. *)
    datatype 't error = EXPECTED of 't
                      | OTHERERROR of string

    (* Lexical input as a combination of a token and its starting position in
       the original text. *)
    type 't lexinput = {pos : pos, token : 't}

    (* The result of an attempted parse. It can either be an error, or a
       successful parse. A successful parse returns the parse result and
       remaining tokens. The parse error is a list of positions, token found (if
       any), and the token expected. *)
    datatype ('a, 't) parseresult = PARSEERROR of {pos : pos,
                                                   got : 't option,
                                                   error : 't error} list
                                  | PARSE of 'a * ('t lexinput list)

    (* A parser is a function that transforms lexical input into a parse result. *)
    type ('a, 't) parser = 't lexinput list -> ('a, 't) parseresult


    (* Compare two positions for their order. *)
    val comppos : pos -> pos -> order

    (* Sequences two parsers, ignoring the output of the first one. *)
    val ignore : ('a, 't) parser -> ('b, 't) parser -> ('b, 't) parser

    (* Uses the output of one parser to create a new one. *)
    val bind : ('a, 't) parser -> ('a -> ('b, 't) parser) -> ('b, 't) parser

    (* A parser that returns a given value without parsing anything. *)
    val ret : 'a -> ('a, 't) parser

    (* Map a function over the output of a parser. *)
    val pmap : ('a -> 'b) -> ('a, 't) parser -> ('b, 't) parser

    (* If the first parser matches, then returns its output, else try the second
       parser. *)
    val alt : ('a, 't) parser -> ('a, 't) parser -> ('a, 't) parser

    (* Matches a single token. *)
    val token : ('t, 't) parser

    (* Matche a single token. *)
    val match : ''t -> (''t, ''t) parser


    (* Derived parsers *)

    (* Matches any of a list of tokens. At least one token is required. *)
    val matchAnyOf : ''t -> ''t list -> (''t, ''t) parser

    (* Optionally parse a parser. *)
    val poption : ('a, 't) parser -> ('a option, 't) parser

    (* Parse a parser many times. *)
    val many : ('a, 't) parser -> ('a list, 't) parser

    (* Parse a parser one or more times. *)
    val many1 : ('a, 't) parser -> ('a list, 't) parser

end
