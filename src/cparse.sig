
signature CPARSE = sig

    (* A character parser. *)
    type 'a cparser = ('a, char) Parse.parser

    (* Parses a cparser over a string. *)
    val cparse : 'a cparser -> string -> ('a, char) Parse.parseresult

end
