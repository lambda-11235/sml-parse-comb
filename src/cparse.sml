
structure CParse : CPARSE = struct

open Parse

type 'a cparser = ('a, char) parser

fun tolexinput s = (labelpos 0 0 (explode s))
and labelpos _ _ [] = []
  | labelpos col row (#"\n" :: cs) = {pos = POS {column = col, row = row}, token = #"\n"} :: (labelpos 0 (row + 1) cs)
  | labelpos col row (#"\r" :: cs) = {pos = POS {column = col, row = row}, token = #"\n"} :: (labelpos 0 (row + 1) cs)
  | labelpos col row (c :: cs) = {pos = POS {column = col, row = row}, token = c} :: (labelpos (col + 1) row cs)

fun cparse p s = p (tolexinput s)

end
