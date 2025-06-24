open Printf
open Yojson.Basic.Util

let debug_parse () =
  try
    printf "1. Opening JSON file...\n"; flush_all ();
    let json = Yojson.Basic.from_file "machines/unary_add.json" in
    printf "2. JSON loaded, parsing name...\n"; flush_all ();
    let name = json |> member "name" |> to_string in
    printf "3. Name: %s\n" name; flush_all ();
    
    printf "4. Parsing alphabet...\n"; flush_all ();
    let alphabet = json |> member "alphabet" |> to_list |> List.map to_string in
    printf "5. Alphabet length: %d\n" (List.length alphabet); flush_all ();
    
    printf "6. Parsing transitions...\n"; flush_all ();
    let transitions_json = json |> member "transitions" |> to_assoc in
    printf "7. Transitions states: %d\n" (List.length transitions_json); flush_all ();
    
    printf "All parsing successful!\n"; flush_all ();
  with
  | e -> printf "Error: %s\n" (Printexc.to_string e); flush_all ()

let () = debug_parse ()
