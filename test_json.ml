open Printf

let test_json () =
  try
    let json = Yojson.Basic.from_file "machines/unary_add.json" in
    printf "JSON loaded successfully\n";
    let name = Yojson.Basic.Util.(json |> member "name" |> to_string) in
    printf "Machine name: %s\n" name;
    flush_all ()
  with
  | e -> printf "Error: %s\n" (Printexc.to_string e)

let () = test_json ()
