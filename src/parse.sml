
structure Parse : PARSE = struct

datatype pos = POS of {column : int, row : int}
             | EOF

datatype 't error = EXPECTED of 't
                  | OTHERERROR of string

type 't lexinput = {pos : pos, token : 't}

datatype ('a, 't) parseresult = PARSEERROR of {pos : pos,
                                               got : 't option,
                                               error : 't error} list
                              | PARSE of 'a * ('t lexinput list)

type ('a, 't) parser = 't lexinput list -> ('a, 't) parseresult


fun comppos p1 p2 = case (p1, p2) of
                        (EOF, EOF) => EQUAL
                      | (_, EOF) => LESS
                      | (EOF, _) => GREATER
                      | (POS p1', POS p2') =>
                        if #row p1' < #row p2' then
                            LESS
                        else if #row p1' > #row p2' then
                            GREATER
                        else if #column p1' < #column p2' then
                            LESS
                        else if #column p1' > #column p2' then
                            GREATER
                        else
                            EQUAL

fun ignore p1 p2 ts = case p1 ts of
                          PARSEERROR err => PARSEERROR err
                        | PARSE (_, ts') => p2 ts'

fun bind p1 p2 ts = case p1 ts of
                          PARSEERROR err => PARSEERROR err
                        | PARSE (x, ts') => p2 x ts'

fun ret x ts = PARSE (x, ts)

fun pmap f p ts = case p ts of
                      PARSEERROR err => PARSEERROR err
                    | PARSE (x, ts') => PARSE (f x, ts')

fun alt p1 p2 ts = case p1 ts of
                       PARSEERROR err => (case p2 ts of
                                              PARSEERROR err' => PARSEERROR (err @ err')
                                            | PARSE pr' => PARSE pr')
                     | PARSE pr => PARSE pr

fun token [] = PARSEERROR [{pos = EOF, got = NONE,
                            error = OTHERERROR "Expected token, found EOF"}]
  | token (t :: ts) = PARSE (#token t, ts)

fun match x [] = PARSEERROR [{pos = EOF, got = NONE, error = EXPECTED x}]
  | match x (t :: ts) = if x = (#token t) then
                            PARSE (x, ts)
                        else
                            PARSEERROR [{pos = #pos t, got = SOME (#token t),
                                         error = EXPECTED x}]


(* Derived parsers *)

fun poption p = alt (pmap SOME p) (ret NONE)

fun many p = bind (poption p) (fn ox => case ox of
                                            NONE => ret []
                                          | (SOME x) =>
                                            bind (many p) (fn xs => ret (x::xs)))

fun many1 p = bind p (fn x => bind (many p) (fn xs => ret (x::xs)))

end
